data "terraform_remote_state" "stage1" {
  backend = "azurerm"
  config = {
    resource_group_name  = "RG-Backend-2"
    storage_account_name = "saterraformstatenewapp"
    container_name       = "scterraformstatenewapp"
    key                  = "stage1.terraform.tfstate"
  }
}

module "kv" {
  source  = "./kv"
  env     = var.env
  project = var.project
  owner_email = var.owner_email
  aks_node_resource_group = data.terraform_remote_state.stage1.outputs.aks_output.aks_node_resource_group
}
