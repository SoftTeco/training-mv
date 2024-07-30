module "aks" {
  source                    = "./aks"
  env                       = var.env
  project                   = var.project
  rg_location               = var.rg_location
  vm_size                   = var.vm_size
  node_count                = var.node_count
  spot_max_price            = var.spot_max_price
  nodepool_name             = var.nodepool_name
  kv_id                     = module.kv.kv_id
  aks_identity_id           = module.kv.aks_identity_id
  aks_identity_principal_id = module.kv.aks_identity_principal_id
  maxverbitskiy_identity_id = module.kv.maxverbitskiy_identity_id
}

module "acr" {
  source                    = "./acr"
  env                       = var.env
  project                   = var.project
  rg_name                   = module.aks.rg_name
  rg_location               = var.rg_location
  aks_identity_id           = module.kv.aks_identity_id
  aks_identity_principal_id = module.kv.aks_identity_principal_id
}

module "kv" {
  source                  = "./kv"
  env                     = var.env
  project                 = var.project
  rg_name                 = module.aks.rg_name
  rg_location             = var.rg_location
  aks_identity_id         = module.kv.aks_identity_id
  vnetwork_id             = module.virtual_network.vnetwork_id
  subnet_id               = module.virtual_network.subnet_id
  oidc_issuer_url         = module.aks.oidc_issuer_url
  aks_id                  = module.aks.aks_id
  rg_id                   = module.aks.rg_id
  owner_email             = var.owner_email
  aks_name                = module.aks.aks_name
  aks_node_resource_group = module.aks.aks_node_resource_group
}

module "virtual_network" {
  source           = "./virtual_network"
  env              = var.env
  project          = var.project
  rg_name          = module.aks.rg_name
  rg_location      = var.rg_location
  address_space    = var.address_space
  address_prefixes = var.address_prefixes
}

