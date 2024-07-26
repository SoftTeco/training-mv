resource "azurerm_resource_group" "rg_new_application" {
  name     = "rg_${var.project}"
  location = var.rg_location
}

data "azurerm_resource_group" "rg2" {
  name     = azurerm_kubernetes_cluster.aks_new_application.node_resource_group
  #location = var.rg_location
}

resource "azurerm_kubernetes_cluster" "aks_new_application" {
  name                          = "aks_${var.project}"
  location                      = var.rg_location
  resource_group_name           = azurerm_resource_group.rg_new_application.name
  dns_prefix                    = "aksnewapplication"
  workload_identity_enabled     = true
  oidc_issuer_enabled           = true

  network_profile {
    network_plugin              = "kubenet"
    outbound_type               = "loadBalancer"
  }

  default_node_pool {
    name                  = "${var.nodepool_name}1"
    vm_size               = var.vm_size
    node_count            = var.node_count
    zones                 = ["1"]
    
    tags = { Environment = var.env }
  }
  

  identity { 
    type = "UserAssigned" 
    identity_ids = [var.aks_identity_id]  
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
  }

  tags = { Environment = var.env }
}

resource "azurerm_kubernetes_cluster_node_pool" "nodepool_azone_2" {
  name                  = "${var.nodepool_name}2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_new_application.id
  vm_size               = var.vm_size
  priority              = "Spot"
  eviction_policy       = "Deallocate"
  spot_max_price        = var.spot_max_price
  node_count            = var.node_count
  zones                 = ["2"]

  tags = { Environment = var.env }
}

resource "azurerm_role_assignment" "assignment_to_aks" {
  scope                = azurerm_kubernetes_cluster.aks_new_application.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = var.aks_identity_principal_id
}

resource "azurerm_role_assignment" "assignment_to_aks_2" {
  scope                = azurerm_kubernetes_cluster.aks_new_application.id
  role_definition_name = "Azure Kubernetes Service Contributor Role"
  principal_id         = var.aks_identity_principal_id
}

data "azurerm_lb" "aks_lb" {
  name                = "kubernetes"
  resource_group_name = azurerm_kubernetes_cluster.aks_new_application.node_resource_group
}
