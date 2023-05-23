variable "agent_count" {
  default = 2
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "aks_service_principal_app_id" {
  sensitive = true
}

variable "aks_service_principal_client_secret" {
  sensitive = true
}

variable "tenant_id"{
    sensitive = true
}

variable "subscription_id"{
    sensitive = true
}

#variable "client_secret"{
#    sensitive = true
#}

variable "client_id"{
    sensitive = true
}

variable "cluster_name" {
}

variable "dns_prefix" {
  default = "k8stest"
}

variable "node_name" {
}

variable "node_vm_size" {
  default = "Standard_B2ms"
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

variable "resource_group_location" {
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "MaxVerbRG"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable service_principal_name {
    type = string 
}
