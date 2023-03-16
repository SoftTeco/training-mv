terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

provider "kubernetes" {
  #load_config_file       = false
  host =  "${var.host}"

  client_certificate = "${var.client_certificate}"
  client_key = "${var.client_key}"
  cluster_ca_certificate = "${var.cluster_ca_certificate}"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address  = "ghcr.io"
    username = "${var.github_host}"
    password = "${var.github_access_token}"
  }
}

#provider "docker" {
  #host     = "ssh://docker@${var.runner_container_ip}:22"
  #host = "ssh://max_verbitskiy@134.17.27.45:22"
  #ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
#}

#terraform {
  #required_providers {
    #yandex = {
      #source = "yandex-cloud/yandex"
    #}
  #}
  #required_version = ">= 0.13"
#}

#provider "yandex" {
  #zone = "ru-central1-b"
#}

resource "kubernetes_secret" "ghcr_auth" {
  metadata {
    name = "github-container-registry-config-${var.namespace_extended_name_number}"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  data = {
    ".dockerconfigjson" = "${var.docker_config_ghcr_auth}"
  }
  type = "kubernetes.io/dockerconfigjson"
}

data "docker_registry_image" "crash-js-app" {
  name = "ghcr.io/${var.github_host}/crash-js-app:${var.js_image}"
}

data "docker_registry_image" "wordpress" {
  name = "ghcr.io/${var.github_host}/wordpress:${var.wp_image}"
}

resource "docker_image" "crash-js-app" {
  name          = data.docker_registry_image.crash-js-app.name
  pull_triggers = [data.docker_registry_image.crash-js-app.sha256_digest]
}

resource "docker_image" "wordpress" {
  name          = data.docker_registry_image.wordpress.name
  pull_triggers = [data.docker_registry_image.wordpress.sha256_digest]
}

resource "kubernetes_namespace" "terraform-k8s" {
  metadata {
    name = "terraform-k8s-${var.environment}-${var.namespace_extended_name_number}"
  }
}

resource "kubernetes_persistent_volume" "wp-db-js-wordpress-pv" {
  metadata {
    name = "wp-db-js-wordpress-pv-${var.environment}-${var.namespace_extended_name_number}"
  }
  spec {
    storage_class_name = "standard"
    capacity = {
      storage = "1Gi"
    }
    /*claim_ref {
      name = "wp-db-js-wordpress-pvc" #"${kubernetes_persistent_volume_claim.wp-db-js-wordpress-pvc.metadata.0.name}"
      namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
    }*/
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      vsphere_volume {
        volume_path = "/compose_data/wordpress-${var.environment}-data"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "wp-db-js-mysql-pv" {
  metadata {
    name = "wp-db-js-mysql-pv-${var.environment}-${var.namespace_extended_name_number}"
  }
  spec {
    storage_class_name = "standard"
    capacity = {
      storage = "1Gi"
    }
    /*claim_ref {
      name = "wp-db-js-mysql-pvc" #"${kubernetes_persistent_volume_claim.wp-db-js-mysql-pvc.metadata.0.name}"
      namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
    }*/
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      vsphere_volume {
        volume_path = "/compose_data/mysql-${var.environment}-data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wp-db-js-wordpress-pvc" {
  metadata {
    name      = "wp-db-js-wordpress-pvc"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "standard"
    volume_name = "${kubernetes_persistent_volume.wp-db-js-wordpress-pv.metadata.0.name}"
  }
}

resource "kubernetes_persistent_volume_claim" "wp-db-js-mysql-pvc" {
  metadata {
    name      = "wp-db-js-mysql-pvc"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "standard"
    volume_name = "${kubernetes_persistent_volume.wp-db-js-mysql-pv.metadata.0.name}"
  }
}

resource "kubernetes_deployment" "wp-db-js-wordpress-deployment-" {
  metadata {
    name      = "${var.deployment_name_wp}"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  spec {
    replicas = "${var.replicas}"
    selector {
      match_labels = {
        project = "wp-db-js-wordpress-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wp-db-js-wordpress-${var.environment}"
        }
      }
      spec {
        image_pull_secrets {
          name = "${kubernetes_secret.ghcr_auth.metadata.0.name}"
        }
        container {
          #image = "ghcr.io/${var.github_host}/wordpress:${var.wp_image}"
          image = "${docker_image.wordpress.name}"
          name  = "wp-db-js-wordpress-${var.environment}"
          env {
            name = "WORDPRESS_DB_HOST"
            value = "wp-db-js-mysql-service.${kubernetes_namespace.terraform-k8s.metadata.0.name}.svc.cluster.local"
          }
          env {
            name = "WORDPRESS_DB_USER"
            value = "${var.db_user}"
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value = "${var.db_password}"
          }
          env {
            name = "WORDPRESS_DB_NAME"
            value = "${var.db_name}"
          }
        }
        volume {
          name = "wp-db-js-wordpress-pv-${var.environment}-test"
          persistent_volume_claim {
            claim_name = "${kubernetes_persistent_volume_claim.wp-db-js-wordpress-pvc.metadata.0.name}"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "wp-db-js-mysql-deployment" {
  metadata {
    name      = "${var.deployment_name_db}"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  spec {
    replicas = "${var.replicas}"
    selector {
      match_labels = {
        project = "wp-db-js-mysql-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wp-db-js-mysql-${var.environment}"
        }
      }
      spec {
        container {
          image = "mysql:5.7"
          name  = "wp-db-js-mysql-${var.environment}"
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "${var.db_password}"
          }
          env {
            name  = "MYSQL_USER"
            value = "${var.db_user}"
          }
          env {
            name  = "MYSQL_PASSWORD"
            value = "${var.db_password}"
          }
          env {
            name  = "MYSQL_DATABASE"
            value = "${var.db_name}"
          }
        }
        volume {
          name = "wp-db-js-mysql-pv-${var.environment}-test"
          persistent_volume_claim {
            claim_name = "${kubernetes_persistent_volume_claim.wp-db-js-mysql-pvc.metadata.0.name}"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "wp-db-js-app-deployment" {
  metadata {
    name      = "${var.deployment_name_js}"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  spec {
    replicas = "${var.replicas}"
    selector {
      match_labels = {
        project = "wp-db-js-app-${var.environment}"
      }
    }
    template {
      metadata {
        labels = {
          project = "wp-db-js-app-${var.environment}"
        }
      }
      spec {
        image_pull_secrets {
          name = "${kubernetes_secret.ghcr_auth.metadata.0.name}"
        }
        container {
          #image = "ghcr.io/${var.github_host}/crash-js-app:${var.js_image}"
          image = "${docker_image.crash-js-app.name}"
          name  = "wp-db-js-app-${var.environment}"
          env {
            name  = "ENVIRONMENT"
            value = "${var.environment}"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wp-db-js-mysql-service" {
  metadata {
    name      = "${var.service_name_db}"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  spec {
    selector = {
      project = "wp-db-js-mysql-${var.environment}"
    }
    type = "NodePort"
    port {
      name        = "db-listener"
      //protocol    = "tcp"
      port        = "${var.mysql_deploy_port}"
      target_port = "${var.mysql_target_port}"
    }
  }
}

resource "kubernetes_service" "wp-db-js-wordpress-service" {
  metadata {
    name      = "${var.service_name_wp}"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  spec {
    selector = {
      project = "wp-db-js-wordpress"
    }
    type = "NodePort"
    port {
      name        = "wp-listener"
      //protocol    = "tcp"
      port        = "${var.wp_deploy_port}"
      target_port = "${var.wp_target_port}"
    }
  }
}

resource "kubernetes_service" "wp-db-js-app-service" {
  metadata {
    name      = "${var.service_name_js}"
    namespace = "${kubernetes_namespace.terraform-k8s.metadata.0.name}"
  }
  spec {
    selector = {
      project = "wp-db-js-app"
    }
    type = "NodePort"
    port {
      name        = "app-listener"
      //protocol    = "tcp"
      port        = "${var.js_deploy_port}"
      target_port = "${var.js_target_port}"
    }
  }
}