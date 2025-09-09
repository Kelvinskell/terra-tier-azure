output "backend_addr_pool_id" {
  description = "The Id of the App Gw's backend address pool"
  value       = one(azurerm_application_gateway.network.backend_address_pool).id
}