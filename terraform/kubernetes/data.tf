data "azurerm_resource_group" "rg-wpdbjs" {
  name     = "RG-WPDBJS-${var.environment}"
}

data "azurerm_kubernetes_cluster" "aks-wpdbjs" {
  name                = "aks-WPDBJS-${var.environment}"
  resource_group_name = data.azurerm_resource_group.rg-wpdbjs
}


data "terraform_remote_state" "tfstatefile" {
  backend = "azurerm"
  config = {
    storage_account_name = "saterraformstatewpdbjs"
    container_name       = "scterraformstatewpdbjs"
    key                  = "terraform.tfstateenv:${local.name}"
  }
}

data "azurerm_storage_account" "example" {
  name                = "saterraformstatewpdbjs"
  resource_group_name = "RG-backend"
}
