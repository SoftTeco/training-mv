output "virtual_network_output" {
  value = module.virtual_network
}

output "kv_output" {
  value = module.kv
}

output "acr_output" {
  value = module.acr
}

output "aks_output" {
  value     = module.aks
  sensitive = true
}
