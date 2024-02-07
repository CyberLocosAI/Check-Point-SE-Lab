# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 2.46" # Specify the version you're targeting. Needed for AVD
#     }
#   }
# }

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
  count = var.resource_count
  name  = "FL-SE-AZURE-vnet-${count.index + 1}"
  #address_space       = ["10.${10 * (count.index + 1)}.0.0/16"]
  #Adjusted calculation so we don't run into invalid IP space
  address_space       = ["10.${count.index % 255 + 1}.0.0/16"]
  location            = azurerm_resource_group.FL-SE-AZURE.location
  resource_group_name = azurerm_resource_group.FL-SE-AZURE.name
}

resource "azurerm_subnet" "internal" {
  count                = var.resource_count
  name                 = "internal-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.FL-SE-AZURE.name
  virtual_network_name = azurerm_virtual_network.FL-SE-AZURE[count.index].name
  address_prefixes     = ["10.${count.index % 255 + 1}.0.0/24"]
}

resource "azurerm_subnet" "external" {
  count                = var.resource_count
  name                 = "external-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.FL-SE-AZURE.name
  virtual_network_name = azurerm_virtual_network.FL-SE-AZURE[count.index].name
  address_prefixes     = ["10.${count.index % 255 + 1}.1.0/24"]
}

resource "azurerm_subnet" "dmz" {
  count                = var.resource_count
  name                 = "dmz-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.FL-SE-AZURE.name
  virtual_network_name = azurerm_virtual_network.FL-SE-AZURE[count.index].name
  address_prefixes     = ["10.${count.index % 255 + 1}.2.0/24"]
}

output "vpc_subnet_details" {
  value = {
    for vnet in azurerm_virtual_network.FL-SE-AZURE :
    vnet.name => {
      "address_space" = vnet.address_space
      "subnets" = {
        "internal" = [for s in azurerm_subnet.internal : s.address_prefixes if s.virtual_network_name == vnet.name],
        "external" = [for s in azurerm_subnet.external : s.address_prefixes if s.virtual_network_name == vnet.name],
        "dmz"      = [for s in azurerm_subnet.dmz : s.address_prefixes if s.virtual_network_name == vnet.name]
      }
    }
  }
  description = "Each VPC with its name and every subnet assigned to each VPC."
}
