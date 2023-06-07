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


provider "kubernetes" {
  #config_path = "~/.kube/config"
  host = data.terraform_remote_state.tfstatefile.outputs.host
  client_certificate = data.terraform_remote_state.tfstatefile.outputs.client_certificate
  client_key = data.terraform_remote_state.tfstatefile.outputs.client_key
  cluster_ca_certificate = data.terraform_remote_state.tfstatefile.outputs.cluster_ca_certificate
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address  = "ghcr.io"
    username = "${var.gh-host}"
    password = "${var.gh-access-token}"
  }
}


data "terraform_remote_state" "tfstatefile" {
  backend = "azurerm"
  config = {
    storage_account_name = "saterraformstatewpdbjs"
    container_name       = "scterraformstatewpdbjs"
    key                  = "terraform.tfstateenv:${local.name}"
  }
}

