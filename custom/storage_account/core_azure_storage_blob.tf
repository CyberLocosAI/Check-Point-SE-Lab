/*.DESCRIPTION
The configuration performs the following actions:
1. Configures the Azure Resource Manager (ARM) provider to enable Terraform to interact with Azure resources.
2. Creates an Azure Resource Group named `rg-vm-script-resources` in the `East US` region to organize the resources.
3. Creates an Azure Storage Account named `vmsetupscriptstorage` within the resource group.  
4. Creates a Storage Container named `vm-setup-scripts` in the storage account, with `blob` access type, making the blobs within it publicly accessible. Sensitive files should not be placed here.
5. Uploads a PowerShell script (`SetupVDI.ps1`) to the `vm-setup-scripts` container as a Block Blob, allowing it to be accessed and downloaded publicly.


.NOTES
- Ensure that the `SetupVDI.ps1` script is present in the local directory before running this configuration.
- The storage container is configured for public access, meaning that anyone with the link can access the stored files.
- This configuration assumes that the Azure account and region specified have sufficient quotas and permissions to create these resources.
*/

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