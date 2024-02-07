# Assuming variables admin_username and admin_password are defined in variables.tf

# Public IP Addresses for VMs
resource "azurerm_public_ip" "student_vdi_ip" {
  count                = var.resource_count
  name                 = "student-vdi-ip-${count.index}"
  resource_group_name  = azurerm_resource_group.FL-SE-AZURE.name
  location             = azurerm_resource_group.FL-SE-AZURE.location
  allocation_method    = "Dynamic"
}

# Network Interfaces for VMs
resource "azurerm_network_interface" "student_nic" {
  count               = var.resource_count
  name                = "student-vdi-nic-${count.index}"
  location            = azurerm_resource_group.FL-SE-AZURE.location
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name

  ip_configuration {
    name                          = "external-${count.index}"
    subnet_id                     = element(azurerm_subnet.external.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.student_vdi_ip[count.index].id
  }
}

# Windows Virtual Machines for Students
resource "azurerm_windows_virtual_machine" "student_vdi" {
  count                 = var.resource_count
  name                  = "student-vdi-${count.index}"
  resource_group_name   = azurerm_resource_group.FL-SE-AZURE.name
  location              = azurerm_resource_group.FL-SE-AZURE.location
  size                  = "Standard_DS2_v2"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.student_nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-pro"
    version   = "latest"
  }
}

# Network Security Group and Rule for RDP Access (if not defined in main.tf)
resource "azurerm_network_security_group" "student_nsg" {
  name                = "student-vdi-nsg"
  location            = azurerm_resource_group.FL-SE-AZURE.location
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name

  security_rule {
    name                       = "RDPAccess"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = ["99.35.11.235", "69.237.12.59", "73.85.178.251"] # Use source_address_prefixes for multiple IPs
    destination_address_prefix = "*"
  }
}

# Associate NSGs with Network Interfaces (if required)
resource "azurerm_network_interface_security_group_association" "student_nic_nsg_assoc" {
  count                      = var.resource_count
  network_interface_id       = azurerm_network_interface.student_nic[count.index].id
  network_security_group_id  = azurerm_network_security_group.student_nsg.id
}
