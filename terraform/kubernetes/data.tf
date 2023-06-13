data "azurerm_resource_group" "rg-wpdbjs" {
  #name     = "RG-WPDBJS-${local.name}"
  name      = "${var.rg-name}"
}

data "azurerm_kubernetes_cluster" "aks-wpdbjs" {
  #name                = "aks-WPDBJS-${local.name}"
  name                 = "${var.aks-name}"
  resource_group_name  = data.azurerm_resource_group.rg-wpdbjs
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
