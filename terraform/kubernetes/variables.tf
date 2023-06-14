variable "mysql-user" {sensitive = true}

variable "mysql-password" {sensitive = true}

variable "mysql-name" {sensitive = true}

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

variable "replicas-count" {}

variable "registry" {
    default = "ghcr.io"
}
