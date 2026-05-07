resource "azurerm_storage_container" "secure_data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.lab_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "test_blob" {
  name                   = "securitytest/test-upload.txt"
  storage_account_name   = azurerm_storage_account.lab_storage.name
  storage_container_name = azurerm_storage_container.secure_data.name
  type                   = "Block"
  access_tier            = "Hot"
  source_content         = "Hello from Terraform! This is a test file for AZ-104 Lab 07."
}

resource "azurerm_storage_container_immutability_policy" "time_retention" {
  storage_container_resource_manager_id = azurerm_storage_container.secure_data.resource_manager_id
  immutability_period_in_days           = 180
  depends_on                            = [azurerm_storage_blob.test_blob]
}
