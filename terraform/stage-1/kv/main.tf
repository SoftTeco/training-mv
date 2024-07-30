data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}
data "azuread_user" "Max_Verbitskiy" {
  user_principal_name = var.owner_email
}

data "external" "managed_identities" {
  program = ["python3", "${path.module}/get_managed_identities.py", var.aks_node_resource_group, data.azurerm_client_config.current.subscription_id]
}

locals {
  namespace = "${var.env}"
  service_account_name = "sa-aks-${var.project}"
}  

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false  
}

resource "random_password" "secret_password_new_application" {
 length           = 12
}

resource "random_password" "secret_user_new_application" {
 length           = 6
}

resource "azurerm_key_vault" "kv_new_application" {
  name                        = format("kv${var.project}-%s", random_string.random.result)
  location                    = var.rg_location
  resource_group_name         = var.rg_name
  enable_rbac_authorization   = false
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  public_network_access_enabled = true
  purge_protection_enabled    = false

  sku_name = "standard"

  network_acls {
    bypass = "AzureServices"
    default_action = "Allow"
    #ip_rules = ["0.0.0.0/0"]
    virtual_network_subnet_ids = [var.subnet_id]
  }
}

resource "azurerm_key_vault_access_policy" "access_policy_aks_identity" {
  key_vault_id = azurerm_key_vault.kv_new_application.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.identity_aks_workload.principal_id

  key_permissions = [
      "Get","List","Update","Create","Import","Delete","Recover","Backup","Restore"
  ]

  secret_permissions = [
      "Get","List","Set","Delete","Recover","Backup","Restore", "Purge"
  ]

  storage_permissions = [
      "Get", "List", "Set", "Delete", "Update", "RegenerateKey", "SetSAS", "ListSAS", "GetSAS", "DeleteSAS"
  ]
}

# Ability to access to KV by Author (Max Verbitskiy) inside Azure
resource "azurerm_key_vault_access_policy" "access_policy_maxverbitskiy" {
  key_vault_id = azurerm_key_vault.kv_new_application.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_user.Max_Verbitskiy.object_id

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

resource "azurerm_key_vault_secret" "secret_password_new_application" {
 name         = "${var.project}secretpassword"
 value        = random_password.secret_password_new_application.result
 key_vault_id = azurerm_key_vault.kv_new_application.id

 depends_on = [
    azurerm_key_vault_access_policy.access_policy_aks_identity,
    azurerm_key_vault_access_policy.access_policy_maxverbitskiy
  ]
}

resource "azurerm_key_vault_secret" "secret_user_new_application" {
 name         = "${var.project}secretuser"
 value        = random_password.secret_user_new_application.result
 key_vault_id = azurerm_key_vault.kv_new_application.id

 depends_on = [
    azurerm_key_vault_access_policy.access_policy_aks_identity,
    azurerm_key_vault_access_policy.access_policy_maxverbitskiy
  ]
}

resource "azurerm_private_dns_zone" "kv_dns_zone_new_application" {
  name                = "privatelink.mv_new_application.azure.net"
  resource_group_name = var.rg_name
}
 
resource "azurerm_private_endpoint" "kv_private_endpoint_new_application" {
  name                          = "kv_private_endpoint_${var.project}"
  resource_group_name           = var.rg_name
  location                      = var.rg_location
  subnet_id                     = var.subnet_id
  custom_network_interface_name = "private_endpoint_for_kv"
 
  private_service_connection {
    name                           = "prod_private_endpoint_${var.project}"
    private_connection_resource_id = azurerm_key_vault.kv_new_application.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
 
  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.kv_dns_zone_new_application.name
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_dns_zone_new_application.id]
  }
}
 
resource "azurerm_private_dns_zone_virtual_network_link" "network_link_new_application" {
  name                  = "private_link_${var.project}"
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns_zone_new_application.name
  virtual_network_id    = var.vnetwork_id
  resource_group_name   = var.rg_name
}

resource "azurerm_user_assigned_identity" "identity_user_MaxVerbitskiy" {
  location            = var.rg_location
  name                = "identity_user_max_verbitskiy_${var.project}"
  resource_group_name = var.rg_name
}

resource "azurerm_user_assigned_identity" "identity_aks_workload" {
  name                = "identity_aks_${var.project}"
  location            = var.rg_location
  resource_group_name = var.rg_name
}

resource "azurerm_role_assignment" "assignment_aks_identity" {
  scope                = azurerm_key_vault.kv_new_application.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_user_assigned_identity.identity_aks_workload.principal_id
}
resource "azurerm_role_assignment" "assignment_max_verbtskiy" {
  scope                = azurerm_key_vault.kv_new_application.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_user_assigned_identity.identity_user_MaxVerbitskiy.principal_id
}

resource "azurerm_federated_identity_credential" "federeated_identity_creds_newapplication" {
  name                = azurerm_user_assigned_identity.identity_aks_workload.name
  resource_group_name = azurerm_user_assigned_identity.identity_aks_workload.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.identity_aks_workload.id
  subject             = "system:serviceaccount:${local.namespace}:${local.service_account_name}"
}

# should be commented before create whole infra (dynamic values)
# locals {
#   aks_managed_identity_names = split(",", data.external.managed_identities.result.identity_names)
# }


# data "azurerm_user_assigned_identity" "aks_managed_identities" {
#   for_each            = toset(local.aks_managed_identity_names)
#   name                = each.value
#   resource_group_name = var.aks_node_resource_group
# }
# resource "azurerm_key_vault_access_policy" "access_policy_to_identity_created_by_aks" {
#   for_each     = data.azurerm_user_assigned_identity.aks_managed_identities
#   key_vault_id = azurerm_key_vault.kv_new_application.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = each.value.principal_id

#   key_permissions = [
#       "Get","List","Update","Create","Import","Delete","Recover","Backup","Restore"
#   ]

#   secret_permissions = [
#       "Get","List","Set","Delete","Recover","Backup","Restore","Purge"
#   ]

#   storage_permissions = [
#       "Get",
#   ]
# }
