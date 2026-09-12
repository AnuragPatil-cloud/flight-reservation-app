resource "azurerm_monitor_action_group" "this" {
  name                = "${var.project_name}-${var.environment}-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "flightalerts"

  email_receiver {
    name                    = "admin"
    email_address           = "anuragpatil1703@gmail.com"
    use_common_alert_schema = true
  }
}
