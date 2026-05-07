resource "azurerm_monitor_alert_processing_rule_suppression" "maintenance" {
  name                = "Planned-Maintenance"
  resource_group_name = azurerm_resource_group.rg11.name
  description         = "Suppress notifications during planned maintenance."
  enabled             = true

  scopes = ["/subscriptions/134ae415-4ca7-4972-a44f-48cef5034596"]

  schedule {
    recurrence {
      weekly {
        days_of_week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        start_time   = "22:00:00"
        end_time     = "07:00:00"
      }
    }
    time_zone = "UTC"
  }
}
