variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "database_subnet_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "db_admin_username" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}
