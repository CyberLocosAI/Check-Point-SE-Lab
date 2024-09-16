variable "ubuntu_image" {
  type = map(string)
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2" # Ubuntu 22.04 LTS
    version   = "latest"
  }
}

resource "azurerm_public_ip" "ubuntu_docker_main_public_ip" {
  count               = var.resource_count
  name                = "ubuntu-docker-main-public-ip-${count.index}"
  location            = azurerm_resource_group.FL-SE-AZURE.location
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name
  #allocation_method   = "Dynamic"
  allocation_method   = "Static"  # Change from "Dynamic" to "Static"
  sku                 = "Standard"  # Explicitly define the SKU as "Standard" for the IP address

}

resource "azurerm_network_interface" "ubuntu_docker_main_nic" {
  count               = var.resource_count
  name                = "ubuntu-docker-main-nic-${count.index}"
  location            = azurerm_resource_group.FL-SE-AZURE.location
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.external[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu_docker_main_public_ip[count.index].id
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

output "ubuntu_docker_main_ips" {
  value = {
    for idx in range(var.resource_count) :
    "ubuntu-docker-main-${idx + 1}" => {
      "public_ip"  = azurerm_public_ip.ubuntu_docker_main_public_ip[idx].ip_address
      "private_ip" = azurerm_network_interface.ubuntu_docker_main_nic[idx].ip_configuration[0].private_ip_address
    }
  }
  description = "The public and private IP addresses of the Ubuntu Docker main virtual machines, with counts starting at 1."
}