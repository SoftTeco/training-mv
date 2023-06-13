#variable "client_certificate" {sensitive = true}

#variable "client_key" {sensitive = true}

#variable "cluster_ca_certificate" {sensitive = true}

variable "mysql-user" {sensitive = true}

variable "mysql-password" {sensitive = true}

variable "mysql-name" {sensitive = true}

#variable "host" {sensitive = true}

variable "gh-access-token" {sensitive = true}

variable "docker-config-ghcr-auth" {sensitive = true}

variable "gh-host" {}

variable "environment" {}

variable "wordpress-image" {}

variable "frontend-image" {}

variable "ns-extended-number" {}

variable "frontend-target-port" {}

variable "frontend-deploy-port" {}

variable "wordpress-target-port" {}

variable "wordpress-deploy-port" {}

variable "mysql-target-port" {}

variable "mysql-deploy-port" {}

variable "rg-name" {}

variable "replicas-count" {}

variable "aks-name" {}

variable "registry" {
    default = "ghcr.io"
}
