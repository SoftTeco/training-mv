#----------------- Local( dev/prod )------------------
locals {
  name = "${terraform.workspace}"
  #mysql-address = data.kubernetes_service.svc-wpdbjs-mysql.status.0.load_balancer.0.ingress.0.ip
  mysql-address = data.azurerm_mysql_flexible_server.mysql-wpdbjs.fqdn
}
#-------------------- K8s namespace for each deploy --------------------
resource "kubernetes_namespace" "ns-wpdbjs" {
  metadata {
    name = "ns-wpdbjs-${local.name}-${var.ns-extended-number}"
  }
}
#----------------- K8s secrets (docker cfg/storage secret) --------------
resource "kubernetes_secret" "ghcr-auth" {
  metadata {
    name = "ghcr-config-${var.ns-extended-number}"
    namespace = kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
  data = {
    ".dockerconfigjson" = "${var.docker-config-ghcr-auth}"
  }
  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "storage_wordpress_secret" {
  metadata {
    name = "storage-wordpress-secret-${var.ns-extended-number}"
    namespace = kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }

  data = { "azure.json" = jsonencode({
    tenantId        = data.azurerm_subscription.current.tenant_id
    subscriptionId  = data.azurerm_subscription.current.subscription_id
    resourceGroup   = data.azurerm_resource_group.rg-wpdbjs.name
    aadClientId     = "${var.azure-client-id}"
    aadClientSecret = "${var.azure-client-secret}"
    azurestorageaccountname = "saterraformstatewpdbjs"
    azurestorageaccountkey = "${var.azure-storageaccount-key}"
    })

  }
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
    storage_class_name = "azurefile-csi"
    persistent_volume_source {
      csi {
        driver = "file.csi.azure.com"
        read_only = false
        volume_handle = "test_volumeHandle"
        volume_attributes = {
          resource_group = "RG-WPDBJS-${local.name}"
          share_name = "${data.azurerm_storage_share.sshare-wpdbjs-wordpress.name}"
        }
        node_stage_secret_ref {
          name = kubernetes_secret.storage_wordpress_secret.metadata.0.name
          namespace = kubernetes_secret.storage_wordpress_secret.metadata.0.namespace
        }
      }
    }
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"

    #persistent_volume_source {
     #vsphere_volume {
        #volume_path = "/home/max_verbitskiy/compose_data/wordpress-${local.name}-data"
        ##volume_path = "/new_compose_data/wordpress-${local.name}/wordpress"
      #}
    #}
  }
}
#------------------ K8s pvc creating (wp, db) ------------------------
resource "kubernetes_persistent_volume_claim" "pvc-wpdbjs-wordpress" {
  metadata {
    name      = "pvc-wpdbjs-wordpress-azurefile"
    namespace = kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "azurefile-csi"
    #volume_name = "${kubernetes_persistent_volume.pv-wpdbjs-wordpress.metadata.0.name}"
  }
}
#------------- K8s deployments creating (wp, db, js) ---------------
resource "kubernetes_deployment_v1" "deploy-wpdbjs-wordpress" {
  metadata {
    name      = "deploy-wpdbjs-wordpress"
    labels    = {
      project = "wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
    }
    namespace = kubernetes_namespace.ns-wpdbjs.metadata.0.name
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
            #value = "http://${local.mysql-address}:${var.mysql-deploy-port}"
            #value = "${data.azurerm_mysql_flexible_server.mysql-wpdbjs.fqdn}"
            value = "${var.mysql-host}"
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
          env {
            name = "WORDPRESS_CONFIG_EXTRA"
            value = "define( 'WP_HOME', 'http://localhost:${var.wordpress-target-port}' );"
          }
          env {
            name = "WORDPRESS_CONFIG_EXTRA"
            value = "define( 'WP_SITEURL', 'http://localhost:${var.wordpress-target-port}' );"
          }
          #command = [ "echo", "ServerName 127.0.0.1", ">>", "/etc/apache2/apache2.conf" ]
          #command = [ "echo 'ServerName 127.0.0.1' >> /etc/apache2/apache2.conf", "service apache2 reload" ]
        }
        #volume {
        #  name = "pv-wpdbjs-wordpress-${local.name}"
        #  persistent_volume_claim {
        #    claim_name = "${kubernetes_persistent_volume_claim.pvc-wpdbjs-wordpress.metadata.0.name}"
        #  }
        #}
      }
    }
  }
}
#--------------- K8s hpa creating (wp, db, js) ---------------------
resource "kubernetes_horizontal_pod_autoscaler_v1" "ascale-wpdbjs-wordpress" {
  metadata {
    name = "ascale-wpdbjs-wordpress-${local.name}-${var.ns-extended-number}"
    namespace = kubernetes_namespace.ns-wpdbjs.metadata.0.name
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
    namespace = kubernetes_namespace.ns-wpdbjs.metadata.0.name
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
