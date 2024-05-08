resource "azurerm_container_registry" "ACR-NewApplication" {
  name                = "acr${var.project}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
}

resource "azurerm_role_assignment" "RA-to-AKS" {
  principal_id                     = var.aks_object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.ACR-NewApplication.id
  skip_service_principal_aad_check = true
}
