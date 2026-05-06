resource "azuread_group" "helpdesk" {
  display_name     = "helpdesk"
  security_enabled = true
}

resource "azurerm_role_assignment" "vm_contributor" {
  scope                = azurerm_management_group.az104_mg1.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azuread_group.helpdesk.object_id
}
