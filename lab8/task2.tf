resource "azurerm_managed_disk" "vm1_disk1" {
  name                 = "vm1-disk1"
  location             = azurerm_resource_group.rg8.location
  resource_group_name  = azurerm_resource_group.rg8.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
  zone                 = "1"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm1_disk1_attach" {
  managed_disk_id    = azurerm_managed_disk.vm1_disk1.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm1.id
  lun                = 0
  caching            = "None"
}
