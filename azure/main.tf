provider "azurerm" {
  features {}

  skip_provider_registration = true #skipping this as a last resort

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "FL-SE-AZURE" {
  name     = "FL-SE-AZURE-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "FL-SE-AZURE" {
  count               = 5
  name                = "FL-SE-AZURE-vnet-${count.index + 1}"
  address_space       = ["10.${10 * (count.index + 1)}.0.0/16"]
  location            = azurerm_resource_group.FL-SE-AZURE.location
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name
}

resource "azurerm_subnet" "internal" {
  count                = 5
  name                 = "internal-${(count.index % 5) + 1}"
  resource_group_name  = azurerm_resource_group.FL-SE-AZURE.name
  virtual_network_name = azurerm_virtual_network.FL-SE-AZURE[floor(count.index / 5)].name
  address_prefixes     = ["10.${10 * (floor(count.index / 5) + 1)}.${count.index % 5}.0/24"]
}

resource "azurerm_subnet" "external" {
  count                = 5
  name                 = "external-${(count.index % 5) + 1}"
  resource_group_name  = azurerm_resource_group.FL-SE-AZURE.name
  virtual_network_name = azurerm_virtual_network.FL-SE-AZURE[floor(count.index / 5)].name
  address_prefixes     = ["10.${10 * (floor(count.index / 5) + 1)}.${count.index % 5 + 5}.0/24"]
}

resource "azurerm_subnet" "dmz" {
  count                = 5
  name                 = "dmz-${(count.index % 5) + 1}"
  resource_group_name  = azurerm_resource_group.FL-SE-AZURE.name
  virtual_network_name = azurerm_virtual_network.FL-SE-AZURE[floor(count.index / 5)].name
  address_prefixes     = ["10.${10 * (floor(count.index / 5) + 1)}.${count.index % 5 + 10}.0/24"]
}
