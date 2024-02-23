terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
    inext = {
      source  = "CheckPointSW/infinity-next"
      version = "1.0.3"
    }
  }
}

provider "azurerm" {
  features {}
}

# variable "client_id" {}
# variable "access_key" {}
# variable "admin_username" {}
# variable "admin_password" {}

resource "azurerm_resource_group" "CGWAF" {
  name     = "CGWAF-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "CGWAF_vnet" {
  name                = "CGWAFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = azurerm_resource_group.CGWAF.name
}

resource "azurerm_subnet" "CGWAF_subnet" {
  name                 = "CGWAFSubnet"
  resource_group_name  = azurerm_resource_group.CGWAF.name
  virtual_network_name = azurerm_virtual_network.CGWAF_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "CGWAF_public_ip" {
  name                = "CGWAFPublicIP"
  location            = "East US"
  resource_group_name = azurerm_resource_group.CGWAF.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "CGWAF_nic_public" {
  name                = "CGWAFNICPublic"
  location            = "East US"
  resource_group_name = azurerm_resource_group.CGWAF.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.CGWAF_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.CGWAF_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "web1" {
  name                = "CGWAFWeb1"
  resource_group_name = azurerm_resource_group.CGWAF.name
  location            = "East US"
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.CGWAF_nic_public.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  disable_password_authentication = false

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "pip3 install Flask",
      "echo \"from flask import Flask\napp = Flask(__name__)\n@app.route('/')\ndef hello_world():\n  return 'Hello, World! from Server 1'\nif __name__ == '__main__':\n  app.run(host='0.0.0.0')\" > helloworld1.py",
      "nohup python3 helloworld1.py &"
    ]
  }
}

resource "azurerm_linux_virtual_machine" "web2" {
  name                = "CGWAFWeb2"
  resource_group_name = azurerm_resource_group.CGWAF.name
  location            = "East US"
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.CGWAF_nic_public.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  disable_password_authentication = false

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "pip3 install Flask",
      "echo \"from flask import Flask\napp = Flask(__name__)\n@app.route('/')\ndef hello_world():\n  return 'Hello, World! from Server 2'\nif __name__ == '__main__':\n  app.run(host='0.0.0.0')\" > helloworld2.py",
      "nohup python3 helloworld2.py &"
    ]
  }
}

provider "inext" {
  region = "us"
  client_id  = var.client_id  
  access_key = var.access_key 
}

resource "inext_web_app_asset" "CGWAF_web_app" {
  name            = "CGWAF Web Application"
  profiles        = [inext_appsec_gateway_profile.CGWAF_appsec.id]
  trusted_sources = [inext_trusted_sources.CGWAF_trusted_sources.id]
  upstream_url    = "http://CGWAFWeb1:80"
  urls            = ["http://CGWAFWeb1:80", "http://CGWAFWeb2:80"]
  practice {
    main_mode = "Prevent"
    sub_practices_modes = {
      IPS              = "AccordingToPractice"
      APIAttacks       = "AccordingToPractice"
      SchemaValidation = "Disabled"
      Snort            = "AccordingToPractice"
    }
    id         = inext_web_app_practice.CGWAF_protection.id
    triggers   = [inext_log_trigger.CGWAF_log_trigger.id]
    exceptions = [inext_exceptions.CGWAF_exceptions.id]
  }
  source_identifier {
    identifier = "HeaderKey"
    values     = ["X-CGWAF-Auth"]
  }
}

resource "inext_web_app_practice" "CGWAF_protection" {
  name = "CGWAF API Protection Practice"
  ips {
    performance_impact    = "MediumOrLower"
    severity_level        = "MediumOrAbove"
    protections_from_year = "2016"
    high_confidence       = "Prevent"
    medium_confidence     = "Prevent"
    low_confidence        = "Detect"
  }
  web_attacks {
    minimum_severity = "High"
    advanced_setting {
      csrf_protection      = "Prevent"
      open_redirect        = "Disabled"
      error_disclosure     = "AccordingToPractice"
      body_size            = 1000000
      url_size             = 32768
      header_size          = 102400
      max_object_depth     = 100
      illegal_http_methods = false
    }
  }
}

resource "inext_exceptions" "CGWAF_exceptions" {
  name = "CGWAF Exceptions"
  exception {
    match {
      operator = "or"
      operand {
        operator = "equals"
        key      = "hostName"
        value    = ["www.example.com"]
      }
      operand {
        operator = "and"
        operand {
          operator = "in"
          key      = "sourceIdentifier"
          value    = ["1.1.1.1/24"]
        }
        operand {
          operator = "not-in"
          key      = "countryName"
          value    = ["Ukraine", "Russia"]
        }
      }
      operand {
        operator = "equals"
        key      = "url"
        value    = ["/"]
      }
    }
    action  = "accept"
    comment = "Allow authenticated traffic"
  }
}

resource "inext_trusted_sources" "CGWAF_trusted_sources" {
  name               = "CGWAF Trusted Sources"
  min_num_of_sources = 3
  sources_identifiers = [
    "trusted@example.com",
    "secure@example.com",
    "safe@example.com"
  ]
}

resource "inext_log_trigger" "CGWAF_log_trigger" {
  verbosity                        = "Standard"
  access_control_allow_events      = true
  access_control_drop_events       = false
  extend_logging                   = true
  extend_logging_min_severity      = "High"
  log_to_cloud                     = true
  name                             = "CGWAF Log Trigger"
  response_body                    = true
  web_url_path                     = true
  web_url_query                    = true
}

resource "inext_appsec_gateway_profile" "CGWAF_appsec" {
  name                 = "CGWAF AppSec Gateway Profile"
  profile_sub_type     = "Azure"
  upgrade_mode         = "Automatic"
  max_number_of_agents = 10
}