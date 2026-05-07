resource "azurerm_virtual_network" "vmss_vnet" {
  name                = "vmss-vnet"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name
  address_space       = ["10.82.0.0/20"]
}

resource "azurerm_subnet" "vmss_subnet" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg8.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes     = ["10.82.0.0/24"]
}

resource "azurerm_network_security_group" "vmss_nsg" {
  name                = "vmss1-nsg"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name

  security_rule {
    name                       = "allow-http"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vmss_nsg_assoc" {
  subnet_id                 = azurerm_subnet.vmss_subnet.id
  network_security_group_id = azurerm_network_security_group.vmss_nsg.id
}

resource "azurerm_public_ip" "vmss_lb_pip" {
  name                = "vmss-lb-pip"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "vmss_lb" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.rg8.location
  resource_group_name = azurerm_resource_group.rg8.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss_lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "vmss_backend" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "vmss-backend-pool"
}

resource "azurerm_lb_probe" "vmss_probe" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "http-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "vmss_lb_rule" {
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vmss_backend.id]
  probe_id                       = azurerm_lb_probe.vmss_probe.id
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss1" {
  name                = "vmss1"
  resource_group_name = azurerm_resource_group.rg8.name
  location            = azurerm_resource_group.rg8.location
  sku                 = "Standard_B2s_v2"
  instances           = 1
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  zones               = ["1", "2", "3"]
  upgrade_mode        = "Manual"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "vmss-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.vmss_nsg.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_backend.id]

      public_ip_address {
        name = "vmss-pip"
      }
    }
  }
}
