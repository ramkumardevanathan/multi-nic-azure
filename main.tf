provider "azurerm" {

  subscription_id = var.subscriptionId
  client_id       = var.clientId
  client_secret   = var.clientSecret
  tenant_id       = var.tenantId

  version = "~> 2.56"
  features {}
}

resource "azurerm_resource_group" "group" {
  name     = var.resourceGroup
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name              = "charles-vnet"
  resource_group_name = azurerm_resource_group.group.name
  location          = azurerm_resource_group.group.location
  address_space     = [var.vnet_prefix]
}

resource "azurerm_subnet" "subnets" {
  count             = length(var.subnet_prefixes)
  name              = "subnet-${count.index}"
  resource_group_name = azurerm_resource_group.group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix    = element(var.subnet_prefixes, count.index)
}

resource "azurerm_network_interface" "nics" {
  count             = length(var.nics)
  name              = "nic-${count.index}"
  location          = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name

  ip_configuration {
    name            = "config-${count.index}"
    subnet_id       = element(azurerm_subnet.subnets[*].id, count.index % 4)
    private_ip_address_allocation = "Static"
    private_ip_address = element(var.nics, count.index)
  }
}

locals {
  vm_nics = chunklist(azurerm_network_interface.nics[*].id, 4)
}

resource "azurerm_linux_virtual_machine" "vm" {
  count             = 2
  name              = "azurevm-${count.index}"
  resource_group_name = azurerm_resource_group.group.name
  location          = azurerm_resource_group.group.location
  size              = "Standard_DS3_v2"
  admin_username    = "adminuser"
  network_interface_ids = element(local.vm_nics, count.index)

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
