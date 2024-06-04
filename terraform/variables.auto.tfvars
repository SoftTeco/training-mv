#General
env                     = "dev"
project                 = "newapplication"

#for AKS
rg_location             = "East US"
vm_size                 = "Standard_A2_v2"
node_count              = 1
spot_max_price          = 8
nodepool_name           = "newappzone"

#for Backend Provider
backend_rg_name         = "RG-Backend-2"

#for vpc
address_space           = ["10.0.0.0/16"]
address_prefixes        = ["10.0.1.0/24"]

#for access to myself to azure KV in Azure.com
owner_email             = "m.verbitskiyy@softteco.com"
