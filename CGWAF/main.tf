terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {} 
}

# Azure Resource Group
resource "azurerm_resource_group" "cgwaf" {
  name     = "cgwaf-rg"
  location = "eastus" 
}

# Azure Virtual Network and Subnet
resource "azurerm_virtual_network" "cgwaf_vnet" {
  name                = "cgwaf-vnet"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.cgwaf.location
  resource_group_name = azurerm_resource_group.cgwaf.name
}

resource "azurerm_subnet" "cgwaf_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.cgwaf.name
  virtual_network_name = azurerm_virtual_network.cgwaf_vnet.name
  address_prefixes     = ["10.20.0.0/24"]
}

# Azure Public IP
resource "azurerm_public_ip" "webgoat_public_ip" {
  name                = "webgoat-public-ip"
  location            = azurerm_resource_group.cgwaf.location
  resource_group_name = azurerm_resource_group.cgwaf.name
  allocation_method   = "Static" 
  sku                 = "Basic" 
}

# Azure Container Group (Including WebGoat)
resource "azurerm_container_group" "cgwaf_containers" {
  name                = "cgwaf-containers"
  location            = azurerm_resource_group.cgwaf.location
  resource_group_name = azurerm_resource_group.cgwaf.name
  ip_address_type     = "Public"
  dns_name_label      = "raffiwaftest"
  os_type             = "Linux"

  container {
    name   = "webgoat"
    image  = "webgoat/webgoat:latest" 
    cpu    = 0.5 
    memory = 1
    ports {
      port     = 8080
      protocol = "TCP"
    }
  }
}