output "vnetwork_id" {
  value     = azurerm_virtual_network.vnetwork_new_application.id
  sensitive = true
}

output "subnet_id" {
  value     = azurerm_subnet.subnet_new_application.id
  sensitive = true
}
