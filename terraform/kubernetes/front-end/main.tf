#----------------- Local( dev/prod )------------------
locals {
  name = "${terraform.workspace}"
  wordpress-address = data.kubernetes_service.svc-wpdbjs-wordpress.status.0.load_balancer.0.ingress.0.ip
}

#----------------- Docker config for authentification --------------
resource "kubernetes_secret" "ghcr-auth" {
  metadata {
    name = "ghcr-config-${var.ns-extended-number}"
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
  data = {
    ".dockerconfigjson" = "${var.docker-config-ghcr-auth}"
  }
  type = "kubernetes.io/dockerconfigjson"
}

#------------------ Docker images from GitHub Container Registry (wp, js) ---------------
resource "docker_image" "front-end" {
  name          = data.docker_registry_image.front-end.name
  pull_triggers = [data.docker_registry_image.front-end.sha256_digest]
}
#------------- K8s deployments creating (wp, db, js) ---------------
resource "kubernetes_deployment_v1" "deploy-wpdbjs-frontend" {
  metadata {
    name      = "deploy-wpdbjs-frontend"
    labels    = {
      project = "wpdbjs-frontend-${local.name}-${var.ns-extended-number}"
    }
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
  spec {
    selector {
      match_labels = {
        project = "wpdbjs-frontend-${local.name}-${var.ns-extended-number}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wpdbjs-frontend-${local.name}-${var.ns-extended-number}"
        }
      }
      spec {
        image_pull_secrets {
          name = "${kubernetes_secret.ghcr-auth.metadata.0.name}"
        }
        container {
          image = "${docker_image.front-end.name}"
          name  = "wpdbjs-frontend-${local.name}"
          resources {
            limits = {
              cpu = "15m"
              memory = "128Mi"
            }
            requests = {
              cpu = "6m"
              memory = "64Mi"
            }
          }
          env {
            name  = "ENVIRONMENT"
            value = "${local.name}"
          }
          env {
            name  = "NEXT_PUBLIC_API_URL"
            value = "http://${local.wordpress-address}:${var.wordpress-deploy-port}/graphql"
          }
        }
      }
    }
  }
}

#--------------- K8s hpa creating (wp, db, js) ---------------------
resource "kubernetes_horizontal_pod_autoscaler_v1" "ascale-wpdbjs-frontend" {
  metadata {
    name = "ascale-wpdbjs-frontend-${local.name}-${var.ns-extended-number}"
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }

  spec {
    min_replicas = 3
    max_replicas = 5

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment_v1.deploy-wpdbjs-frontend.metadata.0.name
      api_version = "apps/v1"
    }

    target_cpu_utilization_percentage = 75
  }
}
#---------------- K8s svc creating (wp, db, js) ------------------
resource "kubernetes_service" "svc-wpdbjs-frontend" {
  metadata {
    name      = "svc-wpdbjs-frontend"
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
  spec {
    selector = {
      project = kubernetes_deployment_v1.deploy-wpdbjs-frontend.metadata.0.labels.project
    }
    type = "LoadBalancer"
    port {
      name        = "frontend-listener"
      port        = "${var.frontend-deploy-port}"
      target_port = "${var.frontend-target-port}"
    }
  }
}
