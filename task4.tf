resource "azurerm_management_lock" "rg_lock" {
  name       = "rg-lock"
  scope      = azurerm_resource_group.rg2.id
  lock_level = "CanNotDelete"
  notes      = "Захист resource group від випадкового видалення"

  depends_on = [
    azurerm_resource_group_policy_assignment.inherit_tag,
    azurerm_resource_group_policy_remediation.tag_remediation
  ]
}