resource "azurerm_virtual_network_peering" "core_to_manufacturing" {
  name                      = "CoreServicesVnet-to-ManufacturingVnet"
  resource_group_name       = azurerm_resource_group.rg5.name
  virtual_network_name      = azurerm_virtual_network.core_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.manufacturing_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "manufacturing_to_core" {
  name                      = "ManufacturingVnet-to-CoreServicesVnet"
  resource_group_name       = azurerm_resource_group.rg5.name
  virtual_network_name      = azurerm_virtual_network.manufacturing_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.core_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
