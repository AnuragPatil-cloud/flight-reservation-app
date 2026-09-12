resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "this" {
  name                     = substr("${replace(var.project_name, "-", "")}${random_string.suffix.result}", 0, 24)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "azurerm_storage_container" "this" {
  name                  = "application"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
