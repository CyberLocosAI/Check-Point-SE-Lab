/*
================================================================================
WARNING: TEST FILE FOR CODE SCANNING TOOL EVALUATION

This Terraform configuration file is designed explicitly for testing and 
demonstrating the capabilities of code scanning tools, such as Check Point 
Spectral Ops. It intentionally includes patterns that resemble sensitive 
information, such as hardcoded credentials and API keys, to trigger alerts 
and demonstrate the tool's detection capabilities.

ALL SENSITIVE VALUES HEREIN ARE ENTIRELY FICTITIOUS AND DO NOT CORRESPOND TO 
ANY REAL ACCOUNTS, SERVICES, OR RESOURCES. This file is for demonstration 
purposes only and should not be used in any production environment or 
considered as an example of best practice.

By using this file, you acknowledge the purpose and limitations outlined 
above.

================================================================================
*/

provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  region     = "us-west-2"
}

resource "aws_db_instance" "bad_example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.m3.medium"
  name                 = "mydb"
  username             = "admin"
  password             = "plainTextPassword123!"
  parameter_group_name = "default.mysql5.7"
}

resource "azurerm_storage_account" "bad_example" {
  name                     = "examplestorageaccount"
  resource_group_name      = "example-resources"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_storage_account_sas" "bad_example_sas" {
  connection_string = azurerm_storage_account.bad_example.primary_connection_string
  https_only        = true
  start             = "2020-01-01"
  expiry            = "2025-01-01"
  services          = "b"
  resource_types    = "sco"
  permissions       = "rwdlacup"
  ip_range          = "0.0.0.0-255.255.255.255"
}

resource "digitalocean_droplet" "bad_example" {
  name   = "web-1"
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-18-04-x64"
  region = "nyc1"

  ssh_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbN5Y6DhjEhV9TgBSP...example"
  ]

  connection {
    user     = "root"
    password = "anotherPlainTextPassword"
    type     = "ssh"
    private_key = <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA7kchVb2+PZl...example
-----END RSA PRIVATE KEY-----
EOF
    timeout = "2m"
  }
}

output "aws_db_instance_bad_example_password" {
  value = aws_db_instance.bad_example.password
}

output "do_droplet_root_password" {
  value = digitalocean_droplet.bad_example.connection.password
}

/*
================================================================================
END OF TEST FILE
================================================================================
*/
