resource "azurerm_app_service_source_control_slot" "staging_deploy" {
  slot_id = azurerm_linux_web_app_slot.staging.id

  repo_url           = "https://github.com/Azure-Samples/php-docs-hello-world"
  branch             = "master"
  use_manual_integration = true
}
