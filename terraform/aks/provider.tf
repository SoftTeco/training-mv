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
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  #client_secret = var.client.secret
  client_id = var.client_id
}

