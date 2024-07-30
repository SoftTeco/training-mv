output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_new_application.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_new_application.kube_config_raw
  sensitive = true
}

output "rg_name" {
  value = azurerm_resource_group.rg_new_application.name
  sensitive = true
}

output "rg_id" {
  value = azurerm_resource_group.rg_new_application.id
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.aks_new_application.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.aks_new_application.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.aks_new_application.kube_config[0].host
  sensitive = true
}

output "aks_assigned_identity_pid" {
  value     = azurerm_kubernetes_cluster.aks_new_application.identity[0].principal_id
  sensitive = true
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks_new_application.id
  sensitive = true
}

output "oidc_issuer_url" {
  value     = azurerm_kubernetes_cluster.aks_new_application.oidc_issuer_url
  sensitive = true
}

output "aks_kubelet_identity_oid" {
  value     = azurerm_kubernetes_cluster.aks_new_application.kubelet_identity[0].object_id
  sensitive = true
}

output "aks_name" {
  value     = azurerm_kubernetes_cluster.aks_new_application.name
  sensitive = true
}

output "aks_node_resource_group" {
  value     = azurerm_kubernetes_cluster.aks_new_application.node_resource_group
  sensitive = true
}

output "aks_fqdn" {
  value     = azurerm_kubernetes_cluster.aks_new_application.fqdn
  sensitive = true
}

# output "aks_public_ip" {
#   value = data.azurerm_public_ip.aks_public_ip.ip_address
# }

# output "aks_public_ip" {
#   value = [for ip in data.azurerm_public_ip.aks_public_ip : ip.ip_address]
# }
