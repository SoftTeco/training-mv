resource "azurerm_resource_group" "RG-NewApplication" {
  name     = "RG-${var.project}"
  location = var.RG_location
}

resource "azurerm_kubernetes_cluster" "AKS-NewApplication" {
  name                = "AKS-${var.project}"
  location            = azurerm_resource_group.RG-NewApplication.location
  resource_group_name = azurerm_resource_group.RG-NewApplication.name
  dns_prefix          = "aks${var.project}"

  default_node_pool {
    name                  = "newappzone1"
    vm_size               = var.vm_size
    node_count            = var.node_count
    zones                 = ["1"]

    tags = { Environment = var.env }
  }

  identity { type = "SystemAssigned" }

  tags = { Environment = var.env }
}

resource "azurerm_kubernetes_cluster_node_pool" "NP-azone-2" {
  name                  = "newappzone2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.AKS-NewApplication.id
  vm_size               = var.vm_size
  priority              = "Spot"
  eviction_policy       = "Deallocate"
  spot_max_price        = var.spot_max_price
  node_count            = var.node_count
  zones                 = ["2"]

  tags = { Environment = var.env }
}
