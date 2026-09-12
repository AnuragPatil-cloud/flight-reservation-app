output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "kubernetes_version" {
  value = azurerm_kubernetes_cluster.this.kubernetes_version
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}

output "resource_group_name" {
  value = var.resource_group_name
}
