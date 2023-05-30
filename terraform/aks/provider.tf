terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.56.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "RG-Backend"
      storage_account_name = "saterraformstatewpdbjs"
      container_name       = "scterraformstatewpdbjs"
      key                  = "terraform.tfstate"
  }
}

data "azurerm_resource_group" "rg-backend" {
  name = "RG-Backend"
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}


