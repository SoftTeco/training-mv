#General
env                     = "dev"
project                 = "MVnewApplication"

#for AKS
RG_location             = "East US"
vm_size                 = "Standard_A2_v2"
node_count              = 1
spot_max_price          = 8
nodepool_name           = "newappzone"

#for Backend Provider
backend_rg_name         = "RG-Backend-2"
