resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = "${var.env}"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "3.6.1"
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "${var.env}"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.15.0"
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = "${var.env}"
  chart      = "external-secrets"
  repository = "https://charts.external-secrets.io"
  version    = "v0.9.20"
}
