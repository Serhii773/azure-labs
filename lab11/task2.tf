resource "azurerm_monitor_activity_log_alert" "vm_deleted" {
  name                = "VM was deleted"
  resource_group_name = azurerm_resource_group.rg11.name
  location            = "global"
  scopes              = ["/subscriptions/134ae415-4ca7-4972-a44f-48cef5034596"]
  description         = "A VM in your resource group was deleted"

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/delete"
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_team.id
  }
}
