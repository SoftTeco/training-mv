variable "gh-host" {}

variable "gh-access-token" {sensitive = true}

variable "docker-config-ghcr-auth" {sensitive = true}


variable "frontend-image" {}


variable "frontend-target-port" {}

variable "frontend-deploy-port" {}

variable "wordpress-deploy-port" {}


variable "environment" {}

variable "ns-extended-number" {}

variable "registry" {}
