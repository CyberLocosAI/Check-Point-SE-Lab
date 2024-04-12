# Public IP Addresses for Check Point Gateway VMs
resource "azurerm_public_ip" "checkpoint_gateway_public_ip" {
  count               = length(azurerm_subnet.external.*.id)
  name                = "checkpoint-gateway-public-ip-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Network Interfaces for Check Point Gateway VMs
resource "azurerm_network_interface" "checkpoint_gateway_nic" {
  count               = length(azurerm_subnet.external.*.id)
  name                = "checkpoint-gateway-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.external[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.checkpoint_gateway_public_ip[count.index].id
  }
}

# Deploy Check Point Firewall
resource "azurerm_linux_virtual_machine" "checkpoint_fw" {
  count                = length(azurerm_subnet.external.*.id)
  name                 = "checkpoint-fw-${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.checkpoint_gateway_nic[count.index].id]
  size                 = var.vm_size

  # Specify Check Point image
  source_image_reference {
    publisher = "checkpoint"
    offer     = "check-point-cg-r8120" 
    sku       = "sg-byol" 
    version   = "latest"
  }

  # Plan information required for VMs created from Marketplace images
  plan {
    name      = "sg-byol"
    publisher = "checkpoint"
    product   = "check-point-cg-r8120"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 100 # Define your disk size or use a variable
  }

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
}
