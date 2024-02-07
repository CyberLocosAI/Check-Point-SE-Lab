variable "resource_count" {
  description = "The number of each resource type to create"
  type        = number
  default     = 1
}

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "client_id" {
  description = "The Azure Client ID for the Service Principal"
  type        = string
}

variable "client_secret" {
  description = "The Azure Client Secret for the Service Principal"
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID for the Service Principal"
  type        = string
}

variable "vm_os_offer" {
  description = "The offer detail of the Check Point image from Azure Marketplace"
  type        = string
}
variable "vm_os_sku" {
  description = "The SKU of the Check Point image from Azure Marketplace"
  type        = string
}
variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
}

variable "disk_size" {
  description = "The size of the OS disk for the VM in GB"
  type        = number # Assuming disk size is a number
}
variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
}
variable "admin_password" {
  description = "The administrator password for the virtual machine"
  type        = string
}
variable "bootstrap_script" {
  description = "Bootstrap script to run on VM initialization"
  type        = string
  default     = "" # You can set a default empty string if the script is optional
}
variable "pub_ips_resource_group_name" {
  description = "The name of the resource group for public IPs"
  type        = string
  default     = "pub_IPs" # You can set a default value or leave it without a default
}

variable "ubuntu_monster_vm_size" {
  description = "The size of the Ubuntu Monster virtual machine"
  type        = string
  default     = "Standard_D2s_v3" # You can set a default value or leave it without to require explicit specification
}

variable "vm_count" {
  description = "Number of VMs to create for AVD session hosts"
  type        = number
  default     = 1
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "student_count" {
  description = "The number of student VMs to create"
  type        = number
  default     = 1
}

variable "student_subnet_id" {
  description = "The ID of the subnet where student VMs will be connected"
  type        = string
}
