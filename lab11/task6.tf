resource "azurerm_log_analytics_workspace" "law" {
  name                = "az104-law-11"
  location            = azurerm_resource_group.rg11.location
  resource_group_name = azurerm_resource_group.rg11.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "vm_diag" {
  name                       = "vm-diagnostics"
  target_resource_id         = azurerm_windows_virtual_machine.vm0.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
