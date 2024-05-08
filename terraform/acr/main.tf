resource "azurerm_container_registry" "ACR-NewApplication" {
  name                = "acr${var.project}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
}
