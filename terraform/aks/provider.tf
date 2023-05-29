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
      resource_group_name  = "WPDBJS-RG"
      storage_account_name = "saterraformstatewpdbjs"
      container_name       = "scterraformstatewpdbjs"
      key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}


