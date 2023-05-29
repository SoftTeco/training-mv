resource "random_pet" "rg_name" {
  prefix = "rg-wp-db-js-${var.environment}"
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "workspace-wp-db-js" {
  name                = "wp-db-js-${var.environment}"
  location            = "centralindia"
  resource_group_name = "WPDBJS-RG"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "aks-wp-db-js" {
  name                = "aks-wp-db-js-${var.environment}"
  location            = var.rg_location
  resource_group_name = "NetworkWatcherRG"
  dns_prefix          = "wp-db-js-${var.environment}"

  default_node_pool {
    name       = "wpdbjs${var.environment}"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

