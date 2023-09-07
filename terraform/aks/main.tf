locals {
  name = "${terraform.workspace}"
}

resource "azurerm_resource_group" "rg-wpdbjs" {
  name     = "RG-WPDBJS-${local.name}"
  location = var.rg_location

}

resource "azurerm_kubernetes_cluster" "aks-wpdbjs" {
  name                = "aks-WPDBJS-${local.name}"
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.rg-wpdbjs.name
  dns_prefix          = "pref-wpdbjs"


  default_node_pool {
    name       = "wpdbjs${local.name}"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

