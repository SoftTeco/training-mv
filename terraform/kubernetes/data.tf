data "azurerm_resource_group" "rg-wpdbjs" {
  name     = "RG-WPDBJS-${local.name}"
  #name      = "${var.rg-name}"
}

data "azurerm_kubernetes_cluster" "aks-wpdbjs" {
  name                = "aks-WPDBJS-${local.name}"
  #name                 = "${var.aks-name}"
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

data "azurerm_storage_account" "example" {
  name                = "saterraformstatewpdbjs"
  resource_group_name = "RG-backend"
}

data "docker_registry_image" "front-end" {
  #name = "${var.registry}/${var.gh-host}/front-end:${var.frontend-image}"
  name  = "ghcr.io/isostheneia94/new-nextjs-app:1.0.11"
}

data "docker_registry_image" "wordpress" {
  name = "${var.registry}/${var.gh-host}/wordpress:${var.wordpress-image}"
}
