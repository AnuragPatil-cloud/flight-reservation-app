output "budget_name" {
  value = azurerm_consumption_budget_subscription.this.name
}

output "budget_id" {
  value = azurerm_consumption_budget_subscription.this.id
}
