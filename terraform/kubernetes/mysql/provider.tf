terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}


provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}


provider "kubernetes" {
  host = data.terraform_remote_state.tfstatefile.outputs.host
  client_certificate = base64decode(data.terraform_remote_state.tfstatefile.outputs.client_certificate)
  client_key = base64decode(data.terraform_remote_state.tfstatefile.outputs.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.tfstatefile.outputs.cluster_ca_certificate)
}
