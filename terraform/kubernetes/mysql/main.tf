#----------------- Local( dev/prod )------------------
locals {
  name = "${terraform.workspace}"
}

#-------------------- K8s namespace for each deploy --------------------
resource "kubernetes_namespace" "ns-wpdbjs" {
  metadata {
    name = "ns-wpdbjs-${local.name}-${var.ns-extended-number}"
  }
}

#-------------------- K8s pv creating (wp, db) -------------------------
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
        volume_path = "/home/max_verbitskiy/compose_data/mysql-${local.name}-data/wordpress_${local.name}"
        #volume_path = "/new_compose_data/mysql"
      }
    }
  }
}

#------------------ K8s pvc creating (wp, db) ------------------------
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
resource "kubernetes_deployment_v1" "deploy-wpdbjs-mysql" {
  metadata {
    name      = "deploy-wpdbjs-mysql"
    labels    = {
      project = "wpdbjs-mysql-${local.name}-${var.ns-extended-number}"
    }
    namespace = "${kubernetes_namespace.ns-wpdbjs.metadata.0.name}"
  }
  spec {
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
          #image = "mysql:5.7"
          image = "mysql:8.0.33"
          name  = "wpdbjs-mysql-${local.name}"
          resources {
            limits = {
              cpu = "15m"
              memory = "1024Mi"
            }
            requests = {
              cpu = "6m"
              memory = "1024Mi"
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
  
          #command = [
          #  "mysqld --initialize --user=mysql --pid-file /var/lib/mysql/mysqld.pid --max-connections=1000 --default-time-zone=+00:00 --max_allowed_packet=16M --innodb_log_buffer_size=4M --innodb_log_file_size=16M --explicit_defaults_for_timestamp"
          #]
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

#--------------- K8s hpa creating (wp, db, js) ---------------------
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
