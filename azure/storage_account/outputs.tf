output "blob_storage_account_name" {
  value = azurerm_storage_account.blob_storage.name
}

output "blob_primary_endpoint" {
  value = azurerm_storage_account.blob_storage.primary_blob_endpoint
}

output "blob_storage_account_id" {
  value = azurerm_storage_account.blob_storage.id
}
