locals {
  onprem-location       = "eastus"
  onprem-resource-group = "onprem-vnet-rg"
  prefix-onprem         = "onprem"
}

resource "azurerm_resource_group" "onprem-vnet-rg" {
  name     = local.onprem-resource-group
  location = local.onprem-location
}

resource "azurerm_virtual_network" "onprem-vnet" {
  name                = "onprem-vnet"
  location            = azurerm_resource_group.onprem-vnet-rg.location
  resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
  address_space       = ["192.168.0.0/16"]
  
  tags = {
    environment = "local.prefix-onprem"
  }
}

resource "azurerm_subnet" "onprem-gateway-subnet" {
  name                = "Gateway-subnet"
  resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.onprem-vnet.name
  address_prefixes     = ["192.168.255.224/27"]
}

resource "azurerm_subnet" "onprem-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.onprem-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.onprem-vnet.name
  address_prefixes     = ["192.168.1.128/25"]
}

resource "azurerm_public_ip" "onprem-ip" {
  name                = "${local.prefix-onprem}-pip"
  resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
  location            = azurerm_resource_group.onprem-vnet-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = local.prefix-onprem
  }
}

resource "azurerm_network_interface" "onprem-nic" {
  name                 = "${local.prefix-onprem}-nic"
  location             = azurerm_resource_group.onprem-vnet-rg.location
  resource_group_name  = azurerm_resource_group.onprem-vnet-rg.name
   ip_forwarding_enabled = true

  ip_configuration {
    name                          = local.prefix-onprem
    subnet_id                     = azurerm_subnet.onprem-mgmt.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.onprem-ip.id
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "onprem-nsg" {
  name                = "${local.prefix-onprem}-nsg"
  location            = azurerm_resource_group.onprem-vnet-rg.location
  resource_group_name = azurerm_resource_group.onprem-vnet-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "onprem"
  }
}

resource "azurerm_subnet_network_security_group_association" "mgmt-nsg-association" {
  subnet_id                 = azurerm_subnet.onprem-mgmt.id
  network_security_group_id = azurerm_network_security_group.onprem-nsg.id
}

resource "azurerm_virtual_machine" "onprme-vm" {
  name                  = "${local.prefix-onprem}-vm"
  location              = azurerm_resource_group.onprem-vnet-rg.location
  resource_group_name   = azurerm_resource_group.onprem-vnet-rg.name
  network_interface_ids = [azurerm_network_interface.onprem-nic.id]
  vm_size               = var.vmsize

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${local.prefix-onprem}-vm"
    admin_username = var.username
    admin_password = local.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
   tags = {
    environment = local.prefix-onprem
  }
}

resource "azurerm_public_ip" "onprem-vpn-gateway1-pip" {
  name                = "${local.prefix-onprem}-vpn-gateway1-pip"
  resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
  location            = azurerm_resource_group.onprem-vnet-rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onprem-vpn-gateway" {
  name                = "onprem-vpn-gateway1"
  location            = azurerm_resource_group.onprem-vnet-rg.location
  resource_group_name = azurerm_resource_group.onprem-vnet-rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onprem-vpn-gateway1-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem-gateway-subnet.id
  }
    depends_on = [ azurerm_public_ip.onprem-vpn-gateway1-pip ]
  
}