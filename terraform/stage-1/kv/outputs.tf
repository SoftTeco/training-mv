output "kv_tenant_id" {
  value     = azurerm_key_vault.kv_new_application.tenant_id
  sensitive = true
}

output "kv_name" {
  value     = azurerm_key_vault.kv_new_application.name
  sensitive = false
}

output "config_client_id" {
  value = data.azurerm_client_config.current.client_id
}

output "kv_id" {
  value     = azurerm_key_vault.kv_new_application.id
  sensitive = true
}

output "kv_vault_uri" {
  value     = azurerm_key_vault.kv_new_application.vault_uri
}

output "aks_identity_id" {
  value     = azurerm_user_assigned_identity.identity_aks_workload.id
}

output "maxverbitskiy_identity_id" {
  value     = azurerm_user_assigned_identity.identity_user_MaxVerbitskiy.id
}

output "secret_username" {
  value     = azurerm_key_vault_secret.secret_user_new_application.name
}

output "secret_password" {
  value     = azurerm_key_vault_secret.secret_password_new_application.name
}

output "aks_identity_client_id" {
  value = azurerm_user_assigned_identity.identity_aks_workload.client_id
}

output "aks_identity_principal_id" {
  value = azurerm_user_assigned_identity.identity_aks_workload.principal_id
}

# should be commented before create whole infra (dynamic values)
# output "created_by_aks_identity_name" {
#   value = local.aks_managed_identity_names[0]
# }

# output "created_by_aks_identity_client_id" {
#   value = values(data.azurerm_user_assigned_identity.aks_managed_identities)[0].client_id
# }

