# data "azurerm_client_config" "current" {}

# resource "helm_release" "aks_acr_kv" {
#   name        = "helm-aks-acr-kv"
#   chart       = "./helm_aks_acr_kv"
#   namespace   = "${var.env}"
#   values      = [yamlencode({
#     kv_name                   = module.kv.kv_name
#     kv_tenant_id              = module.kv.kv_tenant_id
#     kv_uri                    = module.kv.kv_vault_uri
#     user_assigned_client_id   = module.kv.aks_identity_client_id
#     secrets                   = [
#                                 { name = module.kv.secret_username },
#                                 { name = module.kv.secret_password }
#     ]
#     secretObjects               = [
#                                   { data = [{ key = "username"},{objectName = module.kv.secret_username}]},
#                                   { data = [{ key = "password"},{objectName = module.kv.secret_password}]},
#                                   { secretName = module.kv.secret_username },
#                                   { secretName = module.kv.secret_password },
#                                   { type = "Opaque" },
#                                   { type = "Opaque" }
#     ]
#     # should be commented before create whole infra (dynamic values)
#     # managed_identity_created_by_aks_client_id = module.kv.created_by_aks_identity_client_id
#   })]
#   force_update = true
# }

# resource "helm_release" "app" {
#   name        = "helm-app"
#   chart       = "./helm_app"
#   namespace   = "${var.env}"
#   values = [yamlencode({
#     replicas_count            = var.deployment_app_replicas_count
#   })]
#   force_update = true
# }

# resource "helm_release" "externalsecrets" {
#   name        = "helm-externalsecrets"
#   chart       = "./helm_externalsecrets"
#   namespace   = "${var.env}"
#   values = [yamlencode({
#       kv_uri                                    = module.kv.kv_vault_uri

#       # should be commented before create whole infra (dynamic values)
#       managed_identity_created_by_aks_client_id = module.kv.created_by_aks_identity_client_id
#   })]
#   force_update = true
# }

# resource "helm_release" "ingress_certs" {
#   name        = "helm-ingress-certs"
#   chart       = "./helm_ingress_certs"
#   namespace   = "${var.env}"
#   values = [yamlencode({
#      owner_email               = var.owner_email
#      personal_fqdn             = var.personal_fqdn
#   })]
#   force_update = true
# }

# should be uncommented before deploying whole infra (dynamic values)
# resource "helm_release" "external_secrets_chart" {
#   name       = "external-secrets"
#   repository = "https://charts.external-secrets.io"
#   chart      = "external-secrets"
#   namespace  = "dev"
#   version    = "v0.9.20"
# }

# resource "helm_release" "ingress_nginx_chart" {
#   name       = "nginx-ingress"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "dev"
#   version    = "3.6.1"

#   set {
#     name  = "controller.replicaCount"
#     value = "2"
#   }

#   set {
#     name  = "controller.nodeSelector"
#     value = jsonencode({
#       "kubernetes.io/os" = "linux"
#     })
#   }

#   set {
#     name  = "controller.service.type"
#     value = "LoadBalancer"
#   }
# }

# resource "helm_release" "cert_manager_chart" {
#   name       = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   namespace  = "dev"
#   version    = "v1.15.0"
# }
