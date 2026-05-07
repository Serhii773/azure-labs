resource "azurerm_virtual_network" "lab_vnet" {
  name                = "vnet-storage-lab"
  resource_group_name = azurerm_resource_group.lab_rg.name
  location            = azurerm_resource_group.lab_rg.location
  address_space       = local.vnet_ip
}

resource "azurerm_subnet" "storage_subnet" {
  name                 = "StorageSubnet"
  resource_group_name  = azurerm_resource_group.lab_rg.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = local.sub_ip
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_storage_share" "lab_share" {
  name                 = "share1"
  storage_account_name = azurerm_storage_account.lab_storage.name
  quota                = 50
  access_tier          = "TransactionOptimized"
}
