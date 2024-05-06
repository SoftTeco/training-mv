variable "mysql-user" {sensitive = true}

variable "mysql-password" {sensitive = true}

variable "mysql-name" {sensitive = true}


variable "gh-host" {}

variable "gh-access-token" {sensitive = true}

variable "docker-config-ghcr-auth" {sensitive = true}


variable "wordpress-image" {}

variable "frontend-image" {}


variable "frontend-target-port" {}

variable "frontend-deploy-port" {}

variable "wordpress-target-port" {}

variable "wordpress-deploy-port" {}

variable "mysql-target-port" {}

variable "mysql-deploy-port" {}


variable "environment" {}

variable "ns-extended-number" {}

variable "replicas-count" {}

variable "registry" {}
