data "azurerm_client_config" "current" {}

resource "helm_release" "aks_acr_kv" {
  name      = "helm-aks-acr-kv"
  chart     = "./helm_aks_acr_kv"
  namespace = var.env
  values = [yamlencode({
    kv_name                 = data.terraform_remote_state.stage1.outputs.kv_output.kv_name
    kv_tenant_id            = data.terraform_remote_state.stage1.outputs.kv_output.kv_tenant_id
    kv_uri                  = data.terraform_remote_state.stage1.outputs.kv_output.kv_vault_uri
    user_assigned_client_id = data.terraform_remote_state.stage1.outputs.kv_output.aks_identity_client_id
    secrets = [
      { name = data.terraform_remote_state.stage1.outputs.kv_output.secret_username },
      { name = data.terraform_remote_state.stage1.outputs.kv_output.secret_password }
    ]
    secretObjects = [
      { data = [{ key = "username" }, { objectName = data.terraform_remote_state.stage1.outputs.kv_output.secret_username }] },
      { data = [{ key = "password" }, { objectName = data.terraform_remote_state.stage1.outputs.kv_output.secret_password }] },
      { secretName = data.terraform_remote_state.stage1.outputs.kv_output.secret_username },
      { secretName = data.terraform_remote_state.stage1.outputs.kv_output.secret_password },
      { type = "Opaque" },
      { type = "Opaque" }
    ]
    # should be commented before create whole infra (dynamic values)
    managed_identity_created_by_aks_client_id = module.kv.created_by_aks_identity_client_id
  })]
  force_update = true
}

resource "helm_release" "app" {
  name      = "helm-app"
  chart     = "./helm_app"
  namespace = var.env
  values = [yamlencode({
    replicas_count = var.deployment_app_replicas_count
  })]
  force_update = true
}

resource "helm_release" "externalsecrets" {
  name      = "helm-externalsecrets"
  chart     = "./helm_externalsecrets"
  namespace = var.env
  values = [yamlencode({
    kv_uri = data.terraform_remote_state.stage1.outputs.kv_output.kv_vault_uri

    # should be commented before create whole infra (dynamic values)
    managed_identity_created_by_aks_client_id = module.kv.created_by_aks_identity_client_id
  })]
  force_update = true
}

resource "helm_release" "ingress_certs" {
  name      = "helm-ingress-certs"
  chart     = "./helm_ingress_certs"
  namespace = var.env
  values = [yamlencode({
    owner_email   = var.owner_email
    personal_fqdn = var.personal_fqdn
  })]
  force_update = true
}
