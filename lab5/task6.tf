resource "azurerm_subnet" "perimeter" {
  name                 = "perimeter"
  resource_group_name  = azurerm_resource_group.rg5.name
  virtual_network_name = azurerm_virtual_network.core_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_route_table" "rt_core" {
  name                          = "rt-CoreServices"
  location                      = azurerm_resource_group.rg5.location
  resource_group_name           = azurerm_resource_group.rg5.name
  disable_bgp_route_propagation = true
}

resource "azurerm_route" "perimeter_to_core" {
  name                   = "PerimetertoCore"
  resource_group_name    = azurerm_resource_group.rg5.name
  route_table_name       = azurerm_route_table.rt_core.name
  address_prefix         = "10.0.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.1.7"
}

resource "azurerm_subnet_route_table_association" "perimeter_rt" {
  subnet_id      = azurerm_subnet.perimeter.id
  route_table_id = azurerm_route_table.rt_core.id
}
