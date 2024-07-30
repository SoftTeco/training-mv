resource "azurerm_virtual_network" "vnetwork_new_application" {
  name                = "vnetwork_${var.project}"
  address_space       = var.address_space
  location            = var.rg_location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "subnet_new_application" {
  name                 = "subnet_${var.project}"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnetwork_new_application.name
  address_prefixes     = var.address_prefixes
  service_endpoints    = ["Microsoft.KeyVault"]
}
