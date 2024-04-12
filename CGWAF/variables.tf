variable "admin_username" {
  description = "Admin username for the CG WAF VMs"
  type        = string
}

variable "admin_password" {
  description = "The password for the CG WAF VM admin user"
  type        = string
}

variable "client_id" {
  description = "Client ID for inext provider authentication"
  type        = string
}

variable "access_key" {
  description = "Access key for inext provider authentication"
  type        = string
}

variable "checkpoint_token" {
  description = "App token from profile in Infinity Portal"
  type        = string
}
