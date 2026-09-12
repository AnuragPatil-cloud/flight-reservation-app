output "ci_public_ip" {
  value = azurerm_public_ip.this["ci"].ip_address
}

output "ci_private_ip" {
  value = azurerm_network_interface.this["ci"].private_ip_address
}

output "monitoring_public_ip" {
  value = azurerm_public_ip.this["monitoring"].ip_address
}

output "monitoring_private_ip" {
  value = azurerm_network_interface.this["monitoring"].private_ip_address
}
