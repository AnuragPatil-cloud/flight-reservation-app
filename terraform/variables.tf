variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "vm_location" {
  type        = string
  description = "Region for CI and monitoring VMs"
  default     = "westindia"
}

variable "aks_location" {
  type        = string
  description = "Region for AKS"
  default     = "australiaeast"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "admin_username" {
  type        = string
  description = "Linux administrator username"
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
}

variable "vm_size" {
  type        = string
  description = "VM size for CI and monitoring"
  default     = "Standard_B2als_v2"
}

variable "aks_node_vm_size" {
  type        = string
  description = "AKS node VM size"
  default     = "Standard_D2ds_v6"
}
