provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vm_script_resources" {
  name     = "rg-vm-script-resources"
  location = "East US"
}

resource "azurerm_storage_account" "vm_script_storage" {
  name                     = "vmsetupscriptstorage"
  resource_group_name      = azurerm_resource_group.vm_script_resources.name
  location                 = azurerm_resource_group.vm_script_resources.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "vm_script_container" {
  name                  = "vm-setup-scripts"
  storage_account_name  = azurerm_storage_account.vm_script_storage.name
  container_access_type = "blob"  # Updated to make the container public
}

resource "azurerm_storage_blob" "setup_script_blob" {
  name                   = "SetupVDI.ps1"
  storage_account_name   = azurerm_storage_account.vm_script_storage.name
  storage_container_name = azurerm_storage_container.vm_script_container.name
  type                   = "Block"
  source                 = "SetupVDI.ps1"
  content_type           = "application/octet-stream"
}