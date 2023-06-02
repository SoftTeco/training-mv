locals {
  name = "${terraform.workspace}"
}

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

data "docker_registry_image" "front-end" {
  name = "ghcr.io/${var.gh-host}/front-end:${var.frontend-image}"
}

data "docker_registry_image" "wordpress" {
  name = "ghcr.io/${var.gh-host}/wordpress:${var.wordpress-image}"
}

resource "docker_image" "front-end" {
  name          = data.docker_registry_image.front-end.name
  pull_triggers = [data.docker_registry_image.front-end.sha256_digest]
}

resource "docker_image" "wordpress" {
  name          = data.docker_registry_image.wordpress.name
  pull_triggers = [data.docker_registry_image.wordpress.sha256_digest]
}

resource "kubernetes_namespace" "ns-wpdbjs" {
  metadata {
    name = "ns-wpdbjs-${var.environment}-${var.ns-extended-number}"
  }
}

resource "kubernetes_persistent_volume" "pv-wpdbjs-wordpress" {
  metadata {
    name = "pv-wpdbjs-wordpress-${var.environment}-${var.ns-extended-number}"
  }
  spec {
    storage_class_name = "standard"
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      vsphere_volume {
        volume_path = "/compose_data/wordpress-${var.environment}-data"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "pv-wpdbjs-mysql" {
  metadata {
    name = "pv-wpdbjs-mysql-${var.environment}-${var.ns-extended-number}"
  }
  spec {
    storage_class_name = "standard"
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      vsphere_volume {
        volume_path = "/compose_data/mysql-${var.environment}-data"
      }
    }
  }
}

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
    volume_name = "${kubernetes_persistent_volume.pv-wpdbjs-wordpress.metadata.0.name}"
  }
}

resource "kubernetes_deployment" "deploy-wpdbjs-wordpress" {
  metadata {
    name      = "deploy-wpdbjs-wordpress"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
    replicas = "${var.replicas-count}"
    selector {
      match_labels = {
        project = "wpdbjs-wordpress-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wpdbjs-wordpress-${var.environment}"
        }
      }
      spec {
        image_pull_secrets {
          name = "${kubernetes_secret.ghcr-auth.metadata.0.name}"
        }
        container {
          #image = "ghcr.io/${var.github_host}/wordpress:${var.wp_image}"
          image = "${docker_image.wordpress.name}"
          name  = "wpdbjs-wordpress-${var.environment}"
          env {
            name = "WORDPRESS_DB_HOST"
            value = "svc-wpdbjs-mysql.${kubernetes_namespace.ns-wpdbjs.metadata.0.name}.svc.cluster.local"
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
          name = "pv-wpdbjs-wordpress-${var.environment}"
          persistent_volume_claim {
            claim_name = "${kubernetes_persistent_volume_claim.pvc-wpdbjs-wordpress.metadata.0.name}"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "deploy-wpdbjs-mysql" {
  metadata {
    name      = "deploy-wpdbjs-mysql"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
    replicas = "${var.replicas-count}"
    selector {
      match_labels = {
        project = "wpdbjs-mysql-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wpdbjs-mysql-${var.environment}"
        }
      }
      spec {
        container {
          image = "mysql:5.7"
          name  = "wpdbjs-mysql-${var.environment}"
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
          name = "pv-wpdbjs-${var.environment}"
          persistent_volume_claim {
            claim_name = "${kubernetes_persistent_volume_claim.pvc-wpdbjs-mysql.metadata.0.name}"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "deploy-wpdbjs-frontend" {
  metadata {
    name      = "deploy-wpdbjs-frontend"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
    replicas = "${var.replicas-count}"
    selector {
      match_labels = {
        project = "wpdbjs-frontend-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wpdbjs-frontend-${var.environment}"
        }
      }
      spec {
        image_pull_secrets {
          name = "${kubernetes_secret.ghcr-auth.metadata.0.name}"
        }
        container {
          #image = "ghcr.io/${var.github_host}/front-end:${var.js_image}"
          image = "${docker_image.front-end.name}"
          name  = "wpdbjs-frontend-${var.environment}"
          env {
            name  = "ENVIRONMENT"
            value = "${var.environment}"
          }
        }
      }
    }
  }
}


resource "kubernetes_horizontal_pod_autoscaler" "ascale-wpdbjs-frontend" {
  metadata {
    name = "ascale-wpdbjs-frontend"
  }

  spec {
    min_replicas = 2
    max_replicas = 3

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment.deploy-wpdbjs-frontend.metadata.0.name
    }

    behavior {
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"
        policy {
          period_seconds = 120
          type           = "Pods"
          value          = 1
        }

        policy {
          period_seconds = 310
          type           = "Percent"
          value          = 100
        }
      }
      scale_up {
        stabilization_window_seconds = 600
        select_policy                = "Max"
        policy {
          period_seconds = 180
          type           = "Percent"
          value          = 100
        }
        policy {
          period_seconds = 600
          type           = "Pods"
          value          = 3
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "ascale-wpdbjs-wordpress" {
  metadata {
    name = "ascale-wpdbjs-wordpress"
  }

  spec {
    min_replicas = 2
    max_replicas = 3

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment.deploy-wpdbjs-wordpress.metadata.0.name
    }

    behavior {
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"
        policy {
          period_seconds = 120
          type           = "Pods"
          value          = 1
        }

        policy {
          period_seconds = 310
          type           = "Percent"
          value          = 100
        }
      }
      scale_up {
        stabilization_window_seconds = 600
        select_policy                = "Max"
        policy {
          period_seconds = 180
          type           = "Percent"
          value          = 100
        }
        policy {
          period_seconds = 600
          type           = "Pods"
          value          = 3
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "ascale-wpdbjs-mysql" {
  metadata {
    name = "ascale-wpdbjs-mysql"
  }

  spec {
    min_replicas = 2
    max_replicas = 3

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment.deploy-wpdbjs-mysql.metadata.0.name
    }

    behavior {
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"
        policy {
          period_seconds = 120
          type           = "Pods"
          value          = 1
        }

        policy {
          period_seconds = 310
          type           = "Percent"
          value          = 100
        }
      }
      scale_up {
        stabilization_window_seconds = 600
        select_policy                = "Max"
        policy {
          period_seconds = 180
          type           = "Percent"
          value          = 100
        }
        policy {
          period_seconds = 600
          type           = "Pods"
          value          = 3
        }
      }
    }
  }
}

resource "kubernetes_service" "svc-wpdbjs-mysql" {
  metadata {
    name      = "svc-wpdbjs-mysql"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
    selector = {
      project = "wpdbjs-mysql-${var.environment}"
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
  metadata {
    name      = "svc-wpdbjs-wordpress"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
    selector = {
      project = "wpdbjs-wordpress-${var.environment}"
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
  metadata {
    name      = "svc-wpdbjs-frontend"
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
    selector = {
      project = "wpdbjs-frontend"
    }
    type = "LoadBalancer"
    port {
      name        = "frontend-listener"
      port        = "${var.frontend-deploy-port}"
      target_port = "${var.frontend-target-port}"
    }
  }
}
