resource "azurerm_consumption_budget_subscription" "this" {
  name            = "${var.project_name}-${var.environment}-budget"
  subscription_id = "/subscriptions/${var.subscription_id}"

  amount     = 20
  time_grain = "Monthly"

  time_period {
    start_date = "2026-09-01T00:00:00Z"
    end_date   = "2027-09-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = ["anuragpatil1703@gmail.com"]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = ["anuragpatil1703@gmail.com"]
  }
}
