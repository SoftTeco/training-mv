resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

#data "azurerm_resource_group" "wp-db-js_rg" {
#  name     = "NetworkWatcherRG"
  #location = "westeurope"
#}

#data "azurerm_resources" "example" {
#  resource_group_name = azurerm_resouce_group.wp-db-js_rg.name
#}

#resource "azurerm_resource_group" "wp-db-js_rg" {
#  name     = random_pet.rg_name.prefix
#  location = var.resource_group_location
#}


resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_kubernetes_cluster" "wp-db-js_k8s" {
  name                = var.aks_service_cluster_name
  location            = var.aks_service_resource_group_location
  resource_group_name = "NetworkWatcherRG"
  dns_prefix          = var.aks_service_dns_prefix
  #address_space       = ["10.0.0.0/16"]

  default_node_pool {
    name       = var.aks_service_node_name
    node_count = var.agent_count
    vm_size    = var.aks_service_node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
