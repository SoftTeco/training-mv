variable "env" { type = string }

variable "project" { type = string }

variable "rg_location" { type = string }

variable "vm_size" { type = string }

variable "node_count" { type = number }

variable "spot_max_price" { type = number }

variable "backend_rg_name" { type = string }

variable "nodepool_name" { type = string }

variable "address_space" { type = list(string) }

variable "address_prefixes" { type = list(string) }

variable "owner_email" { type = string }

variable "personal_fqdn" { type = string }

variable "deployment_app_replicas_count" { type = number }
