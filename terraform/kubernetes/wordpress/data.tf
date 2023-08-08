data "azurerm_resource_group" "rg-wpdbjs" {
  name     = "RG-WPDBJS-${local.name}"
}

data "azurerm_kubernetes_cluster" "aks-wpdbjs" {
  name                = "aks-WPDBJS-${local.name}"
  resource_group_name  = data.azurerm_resource_group.rg-wpdbjs.name
}

data "terraform_remote_state" "tfstatefile" {
  backend = "azurerm"
  config = {
    storage_account_name = "saterraformstatewpdbjs"
    container_name       = "scterraformstatewpdbjs"
    key                  = "terraform.tfstateenv:${local.name}"
    resource_group_name  = "RG-backend"
  }
}

data "terraform_remote_state" "wordpressfiles" {
  backend = "azurerm"
  config = {
    storage_account_name = "saterraformstatewpdbjs"
    container_name       = "wpstoragewpdbjs"
    key                  = "wordpress-${local.name}-data"
    resource_group_name  = "RG-backend"
  }
}

data "azurerm_storage_account" "saterraformstate" {
  name                = "saterraformstatewpdbjs"
  resource_group_name = "RG-backend"
}

data "docker_registry_image" "wordpress" {
  name = "${var.registry}/${var.gh-host}/wordpress:${var.wordpress-image}"
}

#data "kubernetes_service" "svc-wpdbjs-mysql" {
  #metadata {
    #name      = "svc-wpdbjs-mysql"
    #namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  #}
#}

data "azurerm_mysql_flexible_server" "mysql-wpdbjs" {
  name                = "mysql-wpdbjs-${local.name}"
  resource_group_name = "RG-WPDBJS-${local.name}"
}

data "azurerm_subscription" "current" {}

data "azurerm_storage_share" "sshare-wpdbjs-wordpress" {
  name                 = "sshare-wpdbjs-wordpress-${local.name}" #"${kubernetes_persistent_volume.pv-wpdbjs-wordpress.metadata.0.name}"
  storage_account_name = "data.azurerm_storage_account.sa${local.name}.name"
}

data "azurerm_storage_account" "sadev" {
  name                = "fc223f71d8f9f4e94bb51a2"
  resource_group_name = "mc_rg-wpdbjs-dev_aks-wpdbjs-dev_centralindia"
}

data "azurerm_storage_account" "saprod" {
  name                = "f680fadad9c2449acb51e86"
  resource_group_name = "mc_rg-wpdbjs-prod_aks-wpdbjs-prod_centralindia"
}
