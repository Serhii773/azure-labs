resource "azurerm_monitor_action_group" "ops_team" {
  name                = "Alert the operations team"
  resource_group_name = azurerm_resource_group.rg11.name
  short_name          = "AlertOpsTeam"

  email_receiver {
    name          = "VM was deleted"
    email_address = "sergiyfenuk134@gmail.com"
  }
}
