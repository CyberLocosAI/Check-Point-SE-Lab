resource "azurerm_network_interface" "nic" {
  count               = 5
  name                = "FL-SE-AZURE-nic-${count.index + 1}"
  location            = azurerm_resource_group.FL-SE-AZURE.location
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = 5
  name                = "FL-SE-AZURE-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name
  location            = azurerm_resource_group.FL-SE-AZURE.location
  size                = "Standard_B1s"

  admin_username      = var.usernames[count.index]
  admin_password      = var.passwords[count.index]

  disable_password_authentication = false  # Add this line to Enable Password Authentication instead of ssh

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  source_image_reference {
    publisher = "canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
