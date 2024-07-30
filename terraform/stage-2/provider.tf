terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.14.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "RG-Backend-2"
    storage_account_name = "saterraformstatenewapp"
    container_name       = "scterraformstatenewapp"
    key                  = "stage2.terraform.tfstate"
  }
}

data "azurerm_resource_group" "rg_backend" {
  name = var.backend_rg_name
}

provider "azurerm" {
  skip_provider_registration = true

  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}


provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.stage1.outputs.aks_output.host #host
    client_certificate     = base64decode(data.terraform_remote_state.stage1.outputs.aks_output.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.stage1.outputs.aks_output.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.stage1.outputs.aks_output.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}
