resource "azurerm_container_registry" "acr_new_application" {
  name                = "acr${var.project}"
  resource_group_name = var.rg_name
  location            = var.rg_location
  sku                 = "Standard"
}

resource "azurerm_role_assignment" "role_assignment_to_aks" {
  principal_id                     = var.aks_identity_principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr_new_application.id
  skip_service_principal_aad_check = true
}
