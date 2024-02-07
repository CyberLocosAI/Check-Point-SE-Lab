variable "ubuntu_image" {
  type = map(string)
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2" # Ubuntu 22.04 LTS
    version   = "latest"
  }
}


resource "azurerm_network_interface" "ubuntu_docker_main_nic" {
  count               = var.resource_count
  name                = "ubuntu-docker-main-nic-${count.index}"
  location            = azurerm_resource_group.FL-SE-AZURE.location
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name

  ip_configuration {
    name                          = "internal" # Changed to "internal" to reflect non-public facing config
    subnet_id                     = azurerm_subnet.external[count.index].id
    private_ip_address_allocation = "Dynamic"
    // Removed the public_ip_address_id attribute
  }
}

resource "azurerm_linux_virtual_machine" "ubuntu_docker_main" {
  count                           = var.resource_count
  name                            = "ubuntu-docker-main-${count.index + 1}"
  resource_group_name             = azurerm_resource_group.FL-SE-AZURE.name
  location                        = azurerm_resource_group.FL-SE-AZURE.location
  size                            = var.ubuntu_monster_vm_size
  admin_username                  = "instructor"
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.ubuntu_docker_main_nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.ubuntu_image.publisher
    offer     = var.ubuntu_image.offer
    sku       = var.ubuntu_image.sku
    version   = var.ubuntu_image.version
  }
}

// Removed the output for public IPs as it's no longer relevant
