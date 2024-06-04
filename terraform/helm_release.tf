data "azurerm_client_config" "current" {}

resource "helm_release" "kv_spc" {
  name        = "kv-spc"
  chart       = "./helm"
  namespace   = "${var.env}"
  values      = [yamlencode({
    kv_name                   = module.kv.kv_name
    kv_tenant_id              = module.kv.kv_tenant_id
    user_assigned_client_id   = module.kv.aks_identity_client_id
    user_assigned_identity_id = module.kv.aks_identity_id
    secrets                   = [
                                { name = module.kv.secret_username },
                                { name = module.kv.secret_password }
    ]
    secretObjects               = [
                                  { data = [{ key = "username"},{objectName = module.kv.secret_username}]},
                                  { data = [{ key = "password"},{objectName = module.kv.secret_password}]},
                                  { secretName = module.kv.secret_username },
                                  { secretName = module.kv.secret_password },
                                  { type = "Opaque" },
                                  { type = "Opaque" }
    ]
  })]
  force_update = true
}
