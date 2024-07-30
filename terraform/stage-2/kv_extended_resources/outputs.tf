output "created_by_aks_identity_name" {
  value = local.aks_managed_identity_names[0]
}

output "created_by_aks_identity_client_id" {
  value = values(data.azurerm_user_assigned_identity.aks_managed_identities)[0].client_id
}

