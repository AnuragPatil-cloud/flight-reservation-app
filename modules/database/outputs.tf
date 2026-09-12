output "mysql_server_name" {
  value = azurerm_mysql_flexible_server.this.name
}

output "mysql_fqdn" {
  value = azurerm_mysql_flexible_server.this.fqdn
}

output "database_name" {
  value = azurerm_mysql_flexible_database.this.name
}

output "admin_username" {
  value = var.db_admin_username
}

output "admin_password" {
  value     = random_password.admin.result
  sensitive = true
}
