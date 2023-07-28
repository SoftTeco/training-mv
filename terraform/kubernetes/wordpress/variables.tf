variable "mysql-user" {sensitive = true}

variable "mysql-password" {sensitive = true}

variable "mysql-name" {sensitive = true}


variable "gh-host" {}

variable "gh-access-token" {sensitive = true}

variable "docker-config-ghcr-auth" {sensitive = true}


variable "wordpress-image" {}


variable "wordpress-target-port" {}

variable "wordpress-deploy-port" {}

variable "mysql-deploy-port" {}


variable "environment" {}

variable "ns-extended-number" {}

variable "registry" {}


variable "azure-client-id" { sensitive = true}

variable "azure-client-secret" { sensitive = true}

variable "azure-storageaccount-key" {   sensitive = true }
