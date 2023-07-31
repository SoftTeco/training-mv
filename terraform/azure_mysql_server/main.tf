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

#--------------------------------------------- STORAGE SHARE
resource "azurerm_storage_share" "sshare_wpdbjs_wordpress" {
  name                 = "ssharewpdbjswordpress"
  storage_account_name = "saterraformstatewpdbjs"
  quota                = 50
}
#--------------------------------------------- STORAGE CLASS
resource "kubernetes_storage_class_v1" "sclass_wpdbjs" {
  metadata {
    name = "sclasswpdbjs"
  }
  storage_provisioner = "file.csi.azure.com"
  reclaim_policy      = "Retain"
  parameters = {
    type = "pd-standard"
    skuName = "Standart_LRS"
  }
  mount_options = ["file_mode=0777", "dir_mode=0777", "mfsymlinks", "uid=1000", "gid=1000", "nobrl", "cache=none"]
}
