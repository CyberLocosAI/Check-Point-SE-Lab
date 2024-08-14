# Public IP Addresses for Check Point VMs
resource "azurerm_public_ip" "checkpoint_public_ip" {
  count               = length(azurerm_subnet.external.*.id)
  name                = "checkpoint-public-ip-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Network Interfaces for Check Point VMs
resource "azurerm_network_interface" "checkpoint_nic" {
  count               = length(azurerm_subnet.external.*.id)
  name                = "checkpoint-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.external[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.checkpoint_public_ip[count.index].id
  }
}

# Check Point Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "checkpoint_vm" {
  count                 = length(azurerm_subnet.external.*.id)
  name                  = "checkpoint-vm-${count.index}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.checkpoint_nic[count.index].id]

  admin_username                  = "adminuser"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  # Plan information for VMs created from Marketplace images
  plan {
    name      = "mgmt-byol"
    publisher = "checkpoint"
    product   = "check-point-cg-r8120"
  }

  source_image_reference {
    publisher = "checkpoint"
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size
  }
}