#----------------- Local( dev/prod )------------------
locals {
  name = "${terraform.workspace}"
  wordpress-address = data.kubernetes_service.svc-wpdbjs-wordpress.status.load_balancer.0.ingress.0.ip
  #wordpress-address = data.kubernetes_service.svc-wpdbjs-wordpress.spec.0.external_ips
  #wordpress-address = data.kubernetes_service.svc-wpdbjs-wordpress.spec.0.load_balancer_ip
}

#----------------- Docker config for authentification --------------
resource "kubernetes_secret" "ghcr-auth" {
  metadata {
    name = "ghcr-config-${var.ns-extended-number}"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
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

resource "docker_image" "wordpress" {
  name          = data.docker_registry_image.wordpress.name
  pull_triggers = [data.docker_registry_image.wordpress.sha256_digest]
}

#-------------------- K8s namespace for each deploy --------------------
resource "kubernetes_namespace" "ns-wpdbjs" {
  metadata {
    name = "ns-wpdbjs-${local.name}-${var.ns-extended-number}"
  }
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
        volume_path = "/compose_data/wordpress-${local.name}-data"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "pv-wpdbjs-mysql" {
  metadata {
    name = "pv-wpdbjs-mysql-${local.name}-${var.ns-extended-number}"
  }
  spec {
    storage_class_name = "standard"
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      vsphere_volume {
        volume_path = "/compose_data/mysql-${local.name}-data"
      }
    }
  }
}

#------------------ K8s pvc creating (wp, db) ------------------------
resource "kubernetes_persistent_volume_claim" "pvc-wpdbjs-wordpress" {
  metadata {
    name      = "pvc-wpdbjs-wordpress"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
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

resource "kubernetes_persistent_volume_claim" "pvc-wpdbjs-mysql" {
  metadata {
    name      = "pvc-wpdbjs-mysql"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "standard"
    volume_name = "${kubernetes_persistent_volume.pv-wpdbjs-mysql.metadata.0.name}"
  }
}


#------------- K8s deployments creating (wp, db, js) ---------------
resource "kubernetes_deployment_v1" "deploy-wpdbjs-wordpress" {
  depends_on = [kubernetes_deployment_v1.deploy-wpdbjs-mysql]
  metadata {
    name      = "deploy-wpdbjs-wordpress"
    labels    = {
      project = "wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
    }
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  #lifecycle {
  #  ignore_changes = [
  #    spec[0].replicas,
  #  ]
  #}
  spec {
    #replicas = "${var.replicas-count}"
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
            value = "${kubernetes_service.svc-wpdbjs-mysql.metadata.0.name}"
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

resource "kubernetes_deployment_v1" "deploy-wpdbjs-mysql" {
  metadata {
    name      = "deploy-wpdbjs-mysql"
    labels    = {
      project = "wpdbjs-mysql-${local.name}-${var.ns-extended-number}"
    }
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  #lifecycle {
  #  ignore_changes = [
  #    spec[0].replicas,
  #  ]
  #}
  spec {
    #replicas = "${var.replicas-count}"
    selector {
      match_labels = {
        project = "wpdbjs-mysql-${local.name}-${var.ns-extended-number}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wpdbjs-mysql-${local.name}-${var.ns-extended-number}"
        }
      }
      spec {
        container {
          image = "mysql:5.7"
          name  = "wpdbjs-mysql-${local.name}"
          resources {
            limits = {
              cpu = "15m"
              memory = "256Mi"
            }
            requests = {
              cpu = "6m"
              memory = "256Mi"
            }
          }
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "${var.mysql-password}"
          }
          env {
            name  = "MYSQL_USER"
            value = "${var.mysql-user}"
          }
          env {
            name  = "MYSQL_PASSWORD"
            value = "${var.mysql-password}"
          }
          env {
            name  = "MYSQL_DATABASE"
            value = "${var.mysql-name}"
          }
        }
        volume {
          name = "pv-wpdbjs-${local.name}"
          persistent_volume_claim {
            claim_name = "${kubernetes_persistent_volume_claim.pvc-wpdbjs-mysql.metadata.0.name}"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "deploy-wpdbjs-frontend" {
  depends_on = [kubernetes_service.svc-wpdbjs-wordpress]
  metadata {
    name      = "deploy-wpdbjs-frontend"
    labels    = {
      project = "wpdbjs-frontend-${local.name}-${var.ns-extended-number}"
    }
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  #lifecycle {
  #  ignore_changes = [
  #    spec[0].replicas,
  #  ]
  #}
  spec {
    #replicas = "${var.replicas-count}"
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
  depends_on = [kubernetes_horizontal_pod_autoscaler_v1.ascale-wpdbjs-wordpress]
  metadata {
    name = "ascale-wpdbjs-frontend-${local.name}-${var.ns-extended-number}"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
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

resource "kubernetes_horizontal_pod_autoscaler_v1" "ascale-wpdbjs-wordpress" {
  depends_on = [kubernetes_horizontal_pod_autoscaler_v1.ascale-wpdbjs-mysql]
  metadata {
    name = "ascale-wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
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

resource "kubernetes_horizontal_pod_autoscaler_v1" "ascale-wpdbjs-mysql" {
  metadata {
    name = "ascale-wpdbjs-mysql-${local.name}-${var.ns-extended-number}"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }

  spec {
    min_replicas = 3
    max_replicas = 5

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment_v1.deploy-wpdbjs-mysql.metadata.0.name
      api_version = "apps/v1"
    }

    target_cpu_utilization_percentage = 75
  }
}

#---------------- K8s svc creating (wp, db, js) ------------------
resource "kubernetes_service" "svc-wpdbjs-mysql" {
  metadata {
    name      = "svc-wpdbjs-mysql"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
    selector = {
      project = kubernetes_deployment_v1.deploy-wpdbjs-mysql.metadata.0.labels.project
    }
    type = "LoadBalancer"
    port {
      name        = "mysql-listener"
      port        = "${var.mysql-deploy-port}"
      target_port = "${var.mysql-target-port}"
    }
  }
}

resource "kubernetes_service" "svc-wpdbjs-wordpress" {
  depends_on = [kubernetes_service.svc-wpdbjs-mysql]
  metadata {
    name      = "svc-wpdbjs-wordpress"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
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

resource "kubernetes_service" "svc-wpdbjs-frontend" {
  depends_on = [kubernetes_service.svc-wpdbjs-wordpress]
  metadata {
    name      = "svc-wpdbjs-frontend"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
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
