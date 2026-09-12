resource "random_password" "admin" {
  length           = 24
  special          = true
  override_special = "!@#%^*()-_=+"
}

resource "random_string" "suffix" {
  length  = 5
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.project_name}-${var.environment}-${random_string.suffix.result}.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.project_name}-${var.environment}-mysql-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_mysql_flexible_server" "this" {
  name                = "${replace(var.project_name, "-", "")}${var.environment}mysql${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  administrator_login    = var.db_admin_username
  administrator_password = random_password.admin.result

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  delegated_subnet_id = var.database_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id

  public_network_access = "Disabled"

  sku_name = var.db_sku_name
  version  = "8.0.21"

  storage {
    size_gb           = 20
    auto_grow_enabled = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.mysql
  ]
}

resource "azurerm_mysql_flexible_database" "this" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
