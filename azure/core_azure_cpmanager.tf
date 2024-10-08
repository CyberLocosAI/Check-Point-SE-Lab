# Public IP Addresses for Check Point VMs
resource "azurerm_public_ip" "checkpoint_public_ip" {
  count               = length(azurerm_subnet.external.*.id)
  name                = "checkpoint-public-ip-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"  # Changed from "Dynamic" to "Static"
  sku                 = "Standard"  # Explicitly define the SKU as "Standard" for the IP address

  timeouts {
    create = "5m"  # Allow more time for static IP creation if Azure is slow
  }
}

# Network Security Group for Check Point Manager
resource "azurerm_network_security_group" "checkpoint_manager_nsg" {
  name                = "checkpoint-manager-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow_https_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  timeouts {
    create = "5m"  # Add a timeout to allow the NSG creation process to complete
  }
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

  depends_on = [azurerm_public_ip.checkpoint_public_ip]  # Ensure public IPs are fully created
}

# Associate NSG with the Network Interface
resource "azurerm_network_interface_security_group_association" "checkpoint_manager_nic_nsg_association" {
  count                    = length(azurerm_network_interface.checkpoint_nic)
  network_interface_id      = azurerm_network_interface.checkpoint_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.checkpoint_manager_nsg.id

  depends_on = [
    azurerm_network_security_group.checkpoint_manager_nsg  # Ensure NSG is fully created before associating
  ]
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

  depends_on = [
    azurerm_network_interface.checkpoint_nic,  # Ensure NICs are created first
    azurerm_network_interface_security_group_association.checkpoint_manager_nic_nsg_association  # Ensure NSG is attached
  ]

  timeouts {
    create = "30m"  # Allow more time for VM creation in case of delays with IP, NSG, etc.
  }
}

# Output block
output "checkpoint_mgmt_details" {
  value = {
    public_ip_addresses  = azurerm_public_ip.checkpoint_public_ip[*].ip_address
    private_ip_addresses = azurerm_network_interface.checkpoint_nic[*].ip_configuration[0].private_ip_address
    subnets              = azurerm_subnet.external[*].id
    hostnames            = azurerm_linux_virtual_machine.checkpoint_vm[*].name
  }
}
