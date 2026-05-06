data "azurerm_policy_definition" "inherit_tag" {
  display_name = "Inherit a tag from the resource group if missing"
}

resource "azurerm_resource_group_policy_assignment" "inherit_tag" {
  name                 = "inherit-cost-center"
  resource_group_id    = azurerm_resource_group.rg2.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag.id
  display_name         = "Inherit the Cost Center tag and its value 000 from the resource group if missing"
  description          = "Inherit the Cost Center tag and its value 000 from the resource group if missing"
  location             = azurerm_resource_group.rg2.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    tagName = { value = "Cost Center" }
  })
}

resource "azurerm_role_assignment" "tag_contributor" {
  scope                = azurerm_resource_group.rg2.id
  role_definition_name = "Tag Contributor"
  principal_id         = azurerm_resource_group_policy_assignment.inherit_tag.identity[0].principal_id
}

resource "azurerm_resource_group_policy_remediation" "tag_remediation" {
  name                 = "cost-center-remediation"
  resource_group_id    = azurerm_resource_group.rg2.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.inherit_tag.id
  depends_on           = [azurerm_role_assignment.tag_contributor]
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "demo" {
  name                     = "az104sa${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg2.name
  location                 = "polandcentral"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = [azurerm_resource_group_policy_assignment.inherit_tag]
}
