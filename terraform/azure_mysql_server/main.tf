locals {
  name = "${terraform.workspace}"
}

resource "azurerm_mysql_flexible_server" "mysql_wpdbjs" {
  name                = "mysql-wpdbjs-${local.name}"
  resource_group_name = data.azurerm_resource_group.rg-wpdbjs.name
  location            = var.rg_location
}

resource "azurerm_mysql_flexible_server_firewall_rule" "mysql_wpdbjs_fw_rule" {
  name                = "all-ip's"
  resource_group_name = data.azurerm_resource_group.rg-wpdbjs.name
  server_name         = azurerm_mysql_flexible_server.mysql_wpdbjs.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
