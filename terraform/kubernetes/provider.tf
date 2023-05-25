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

  #host =  "https://test-prefix-ut4di0f8.hcp.westeurope.azmk8s.io:443" #"20.73.140.95" #"${var.host}"
  #client_certificate = "${var.client_certificate}"
  #client_key = "${var.client_key}"
  #cluster_ca_certificate = "${var.cluster_ca_certificate}"
  config_path = "~/.kube/config"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address  = "ghcr.io"
    username = "${var.github_host}"
    password = "${var.github_access_token}"
  }
}

