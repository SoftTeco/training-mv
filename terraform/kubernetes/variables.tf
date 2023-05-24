variable "client_certificate" {sensitive = true}

variable "client_key" {sensitive = true}

variable "cluster_ca_certificate" {sensitive = true}

variable "db_user" {sensitive = true}

variable "db_password" {sensitive = true}

variable "db_name" {sensitive = true}

variable "host" {sensitive = true}

variable "github_access_token" {sensitive = true}

variable "docker_config_ghcr_auth" {sensitive = true}

variable "github_host" {}

variable "replicas" {}

variable "environment" {}

variable "wp_image_dev" {}

variable "js_image_dev" {}

variable "wp_image_prod" {}

variable "js_image_prod" {}

variable "namespace_extended_name_number" {}

#variable "runner_container_ip" {}

variable "js_target_port_dev" {}

variable "js_deploy_port_dev" {}

variable "wp_target_port_dev" {}

variable "wp_deploy_port_dev" {}

variable "mysql_target_port_dev" {}

variable "mysql_deploy_port_dev" {}

variable "js_target_port_prod" {}

variable "js_deploy_port_prod" {}

variable "wp_target_port_prod" {}

variable "wp_deploy_port_prod" {}

variable "mysql_target_port_prod" {}

variable "mysql_deploy_port_prod" {}

variable "deployment_name_wp" {
  default = "wp-db-js-wordpress-deployment"
}

variable "deployment_name_js" {
  default = "wp-db-js-app-deployment"
}

variable "deployment_name_db" {
  default = "wp-db-js-mysql-deployment"
}

variable "service_name_db" {
  default = "wp-db-js-mysql-service"
}

variable "service_name_wp" {
  default = "wp-db-js-wordpress-service"
}

variable "service_name_js" {
  default = "wp-db-js-app-service"
}
