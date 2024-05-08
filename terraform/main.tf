module "aks" {
 source		    = "./aks"
 env    	    = var.env
 project	    = var.project
 RG_location    = var.RG_location
 vm_size        = var.vm_size
 node_count     = var.node_count
 spot_max_price = var.spot_max_price
}

module "acr" {
 source		                = "./acr"
 env                        = var.env
 project                    = var.project
 resource_group_name        = module.aks.resource_group_name
 resource_group_location    = module.aks.resource_group_location
}

module "kv" {
 source		                = "./kv"
 env                        = var.env
 project                    = var.project
 resource_group_name        = module.aks.resource_group_name
 resource_group_location    = module.aks.resource_group_location
}
