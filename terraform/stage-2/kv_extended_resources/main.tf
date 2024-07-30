data "azurerm_client_config" "current" {}

data "terraform_remote_state" "stage1" {
  backend = "azurerm"
  config = {
    resource_group_name  = "RG-Backend-2"
    storage_account_name = "saterraformstatenewapp"
    container_name       = "scterraformstatenewapp"
    key                  = "stage1.terraform.tfstate"
  }
}

data "external" "managed_identities" {
  program = ["python3", "${path.module}/get_managed_identities.py", var.aks_node_resource_group, data.azurerm_client_config.current.subscription_id]
}


locals {
  aks_managed_identity_names = split(",", data.external.managed_identities.result.identity_names)
}


data "azurerm_user_assigned_identity" "aks_managed_identities" {
  for_each            = toset(local.aks_managed_identity_names)
  name                = each.value
  resource_group_name = var.aks_node_resource_group
}
resource "azurerm_key_vault_access_policy" "access_policy_to_identity_created_by_aks" {
  for_each     = data.azurerm_user_assigned_identity.aks_managed_identities
  key_vault_id = data.terraform_remote_state.stage1.outputs.kv_output.kv_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.principal_id

  key_permissions = [
      "Get","List","Update","Create","Import","Delete","Recover","Backup","Restore"
  ]

  secret_permissions = [
      "Get","List","Set","Delete","Recover","Backup","Restore","Purge"
  ]

  storage_permissions = [
      "Get",
  ]
}
