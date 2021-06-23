provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
  tags = {
    environment = "${var.rg_tag}"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_managed_disk" "main" {
  name                    = "${var.prefix}-md"
  location                = "${var.location}"
  resource_group_name     = azurerm_resource_group.main.name
  storage_account_type    = "Standard_LRS"
  create_option           = "Empty"
  disk_size_gb            = "1"

  tags = {
    environment = "UdacityProject1"
  }
}

# Security group to deny inbound traffic from Internet
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-sg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "DenyInternetInBound"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
}  
resource "azurerm_network_interface_security_group_association" "main" {
  count                          = "${var.countVm}"
  network_interface_id =    azurerm_network_interface.main.id
  network_security_group_id      = azurerm_network_security_group.main.id
}

resource "azurerm_public_ip" "main" {
  name           = "${var.prefix}-PublicIp"
  resource_group_name     = azurerm_resource_group.main.name
  location                = "${var.location}"
  allocation_method       = "Static"
  tags = {
    environment = "UdacityProject1"
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "primary"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name             = azurerm_resource_group.main.name
  loadbalancer_id                 = azurerm_lb.main.id
  name                            = "${var.prefix}-lbBackendpool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main"{
  network_interface_id =    azurerm_network_interface.main.id
  ip_configuration_name    ="UdProConfiguration"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = "${var.countVm}"
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  tags = {
    environment = "UdacityProject1"
  }
}

