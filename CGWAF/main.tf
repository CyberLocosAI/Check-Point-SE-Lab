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

# variable "checkpoint_token" {
#   description = "Token for Check Point CloudGuard AppSec"
#   type        = string
# }

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

# Azure Container Group with both WebGoat and Check Point AppSec Containers
resource "azurerm_container_group" "cgwaf_containers" {
  name                = "cgwaf-containers"
  location            = azurerm_resource_group.cgwaf.location
  resource_group_name = azurerm_resource_group.cgwaf.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "raffiwaftest"
  
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

  container {
    name   = "checkpoint-appsec"
    image  = "checkpoint/cloudguard-appsec-standalone:latest"
    cpu    = 1
    memory = 2
    ports {
      port     = 80
      protocol = "TCP"
    }
    environment_variables = {
      UPSTREAM_URL = "http://webgoat:8080/WebGoat"
      TOKEN        = var.checkpoint_token # Placeholder for your actual token
    }
  }

}

# Output the DNS name to access the application
output "app_dns_name" {
  value = azurerm_container_group.cgwaf_containers.fqdn
}
