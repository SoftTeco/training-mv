variable "tenant_id"{
    sensitive = true
}

variable "subscription_id"{
    sensitive = true
}

variable "client_secret"{
    sensitive = true
}

variable "client_id"{
    sensitive = true
}

variable "aks_service_cluster_name" {
    type = string
}

variable "aks_service_dns_prefix" {
    type = string
}

variable "aks_service_node_name" {
    type = string
}

variable "aks_service_node_vm_size" {
    type = string
}

variable "aks_service_resource_group_location" {
    type = string
}

variable "aks_service_agent_count" {
    type = number
}

# Refer to https://azure.microsoft.com/global-infrastructure/services/?products=monitor for available Log Analytics regions.
variable "log_analytics_workspace_location" {
  default = "westeurope"
}

variable "log_analytics_workspace_name" {
  default = "testLogAnalyticsWorkspaceName"
}

# Refer to https://azure.microsoft.com/pricing/details/monitor/ for Log Analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

variable "resource_group_name_prefix" {
  default     = "MaxVerbRG"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}
