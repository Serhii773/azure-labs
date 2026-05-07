resource "azurerm_subnet" "subnet_appgw" {
  name                 = "subnet-appgw"
  resource_group_name  = azurerm_resource_group.rg6.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.3.224/27"]
}

resource "azurerm_public_ip" "appgw_pip" { 
  name                = "az104-gwpip"
  location            = azurerm_resource_group.rg6.location
  resource_group_name = azurerm_resource_group.rg6.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "az104-appgw"
  resource_group_name = azurerm_resource_group.rg6.name
  location            = azurerm_resource_group.rg6.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.subnet_appgw.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-fe-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name         = "az104-appgwbe"
    ip_addresses = [for nic in azurerm_network_interface.vm_nics : nic.private_ip_address]
  }

  backend_address_pool {
    name         = "az104-imagebe"
    ip_addresses = [azurerm_network_interface.vm_nics[0].private_ip_address]
  }

  backend_address_pool {
    name         = "az104-videobe"
    ip_addresses = [azurerm_network_interface.vm_nics[1].private_ip_address]
  }

  backend_http_settings {
    name                  = "az104-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "az104-listener"
    frontend_ip_configuration_name = "appgw-fe-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name               = "az104-gwrule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "az104-listener"
    url_path_map_name  = "url-path-map"
    priority           = 10
  }

  url_path_map {
    name                               = "url-path-map"
    default_backend_address_pool_name  = "az104-appgwbe"
    default_backend_http_settings_name = "az104-http"

    path_rule {
      name                       = "images"
      paths                      = ["/image/*"]
      backend_address_pool_name  = "az104-imagebe"
      backend_http_settings_name = "az104-http"
    }

    path_rule {
      name                       = "videos"
      paths                      = ["/video/*"]
      backend_address_pool_name  = "az104-videobe"
      backend_http_settings_name = "az104-http"
    }
  }
}

output "appgw_public_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}
