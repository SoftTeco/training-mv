output "client_certificate" {
  value     = azurerm_kubernetes_cluster.AKS-NewApplication.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.AKS-NewApplication.kube_config_raw
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.RG-NewApplication.name
}

output "resource_group_location" {
  value = azurerm_resource_group.RG-NewApplication.location
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.AKS-NewApplication.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.AKS-NewApplication.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.AKS-NewApplication.kube_config[0].host
  sensitive = true
}

output "aks_object_id" {
  value     = azurerm_kubernetes_cluster.AKS-NewApplication.identity[0].principal_id
  sensitive = true
}
