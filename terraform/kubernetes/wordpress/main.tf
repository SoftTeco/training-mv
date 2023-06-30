#----------------- Local( dev/prod )------------------
locals {
  name = "${terraform.workspace}"
  mysql-address = data.kubernetes_service.svc-wpdbjs-mysql.status.0.load_balancer.0.ingress.0.ip
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
resource "docker_image" "wordpress" {
  name          = data.docker_registry_image.wordpress.name
  pull_triggers = [data.docker_registry_image.wordpress.sha256_digest]
}
#-------------------- K8s pv creating (wp, db) -------------------------
resource "kubernetes_persistent_volume" "pv-wpdbjs-wordpress" {
  metadata {
    name = "pv-wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
  }
  spec {
    storage_class_name = "standard"
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      vsphere_volume {
        #volume_path = "/compose_data/wordpress-${local.name}-data"
        volume_path = "/srv/www/wordpress-${local.name}/wordpress"
      }
    }
  }
}
#------------------ K8s pvc creating (wp, db) ------------------------
resource "kubernetes_persistent_volume_claim" "pvc-wpdbjs-wordpress" {
  metadata {
    name      = "pvc-wpdbjs-wordpress"
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "standard"
    volume_name = "${kubernetes_persistent_volume.pv-wpdbjs-wordpress.metadata.0.name}"
  }
}
#------------- K8s deployments creating (wp, db, js) ---------------
resource "kubernetes_deployment_v1" "deploy-wpdbjs-wordpress" {
  metadata {
    name      = "deploy-wpdbjs-wordpress"
    labels    = {
      project = "wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
    }
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
  spec {
    selector {
      match_labels = {
        project = "wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
        }
      }
      spec {
        image_pull_secrets {
          name = "${kubernetes_secret.ghcr-auth.metadata.0.name}"
        }
        container {
          image = "${docker_image.wordpress.name}"
          name  = "wpdbjs-wordpress-${local.name}"
          resources {
            limits = {
              cpu = "15m"
              memory = "64Mi"
            }
            requests = {
              cpu = "6m"
              memory = "32Mi"
            }
          }
          env {
            name = "WORDPRESS_DB_HOST"
            #value = "${kubernetes_service.svc-wpdbjs-mysql.kubernetes_namespace.ns-wpdbjs.svc.cluster.local}"
            #value = "${kubernetes_service.svc-wpdbjs-mysql.metadata.0.name}"
            value = "http://${local.mysql-address}:${var.mysql-deploy-port}"
            #value = "svc-wpdbjs-mysql"
          }
          env {
            name = "WORDPRESS_DB_USER"
            value = "${var.mysql-user}"
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value = "${var.mysql-password}"
          }
          env {
            name = "WORDPRESS_DB_NAME"
            value = "${var.mysql-name}"
          }
        }
        volume {
          name = "pv-wpdbjs-wordpress-${local.name}"
          persistent_volume_claim {
            claim_name = "${kubernetes_persistent_volume_claim.pvc-wpdbjs-wordpress.metadata.0.name}"
          }
        }
      }
    }
  }
}
#--------------- K8s hpa creating (wp, db, js) ---------------------
resource "kubernetes_horizontal_pod_autoscaler_v1" "ascale-wpdbjs-wordpress" {
  metadata {
    name = "ascale-wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }

  spec {
    min_replicas = 3
    max_replicas = 5

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment_v1.deploy-wpdbjs-wordpress.metadata.0.name
      api_version = "apps/v1"
    }

    target_cpu_utilization_percentage = 75
  }
}
#---------------- K8s svc creating (wp, db, js) ------------------
resource "kubernetes_service" "svc-wpdbjs-wordpress" {
  metadata {
    name      = "svc-wpdbjs-wordpress"
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
  spec {
    selector = {
      project = kubernetes_deployment_v1.deploy-wpdbjs-wordpress.metadata.0.labels.project
    }
    type = "LoadBalancer"
    port {
      name        = "wordpress-listener"
      port        = "${var.wordpress-deploy-port}"
      target_port = "${var.wordpress-target-port}"
    }
  }
}
