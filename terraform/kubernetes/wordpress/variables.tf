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


variable "azure-client-id" { sensensitive = true}

variable "azure-client-secret" { sesensitive = true}

variable "azure-storageaccount-key" { sensensitive = true }
