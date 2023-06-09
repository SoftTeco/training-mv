data "azurerm_resource_group" "rg-wpdbjs" {
  name     = "RG-WPDBJS-${local.name}"
}

data "azurerm_kubernetes_cluster" "aks-wpdbjs" {
  name                = "aks-WPDBJS-${local.name}"
  resource_group_name = data.azurerm_resource_group.rg-wpdbjs
}

