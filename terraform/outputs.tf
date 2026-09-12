output "vm_resource_group_name" {
  value = module.vm_network.resource_group_name
}

output "aks_resource_group_name" {
  value = module.aks_network.resource_group_name
}

output "vm_vnet_name" {
  value = module.vm_network.vnet_name
}

output "aks_vnet_name" {
  value = module.aks_network.vnet_name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "aks_kubernetes_version" {
  value = module.aks.kubernetes_version
}

output "aks_oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "ci_vm_public_ip" {
  value = module.vm.ci_public_ip
}

output "ci_vm_private_ip" {
  value = module.vm.ci_private_ip
}

output "monitoring_vm_public_ip" {
  value = module.vm.monitoring_public_ip
}

output "monitoring_vm_private_ip" {
  value = module.vm.monitoring_private_ip
}
