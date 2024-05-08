terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "RG-Backend-2"
      storage_account_name = "saterraformstatenewapp"
      container_name       = "scterraformstatenewapp"
      key                  = "terraform.tfstate"
  }
}

data "azurerm_resource_group" "rg-backend" {
  name = "RG-Backend-2"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}
