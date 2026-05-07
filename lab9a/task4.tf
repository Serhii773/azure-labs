resource "azurerm_web_app_active_slot" "swap" {
  slot_id = azurerm_linux_web_app_slot.staging.id
}
