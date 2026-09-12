variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "subnets" {
  type = map(string)
}
