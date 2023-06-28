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


data "azurerm_storage_account" "saterraformstate" {
  name                = "saterraformstatewpdbjs"
  resource_group_name = "RG-backend"
}

data "docker_registry_image" "front-end" {
  #name = "${var.registry}/${var.gh-host}/front-end:${var.frontend-image}"
  name = "ghcr.io/isostheneia94/new-nextjs-app:1.0.11"
}

data "kubernetes_service" "svc-wpdbjs-wordpress" {
  metadata {
    name      = "svc-wpdbjs-wordpress"
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
}

data "kubernetes_namespace" "ns-wpdbjs" {
  metadata {
    name = "ns-wpdbjs-${local.name}-${var.ns-extended-number}"
  }
}

data "kubernetes_secret" "example" {
  metadata {
    name = "ghcr-config-${var.ns-extended-number}"
    namespace = data.kubernetes_namespace.ns-wpdbjs.metadata.0.name
  }
}
