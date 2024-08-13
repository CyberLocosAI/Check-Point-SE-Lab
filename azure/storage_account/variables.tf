variable "blob_resource_group_name" {
  description = "The name of the resource group for blob storage."
  type        = string
}

variable "blob_location" {
  description = "The location of the blob storage."
  type        = string
}

variable "blob_storage_account_name" {
  description = "The name of the storage account."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the private endpoint."
  type        = string
}
