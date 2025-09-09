# Private Endpoint for secure access
resource "azurerm_private_dns_zone" "nfs_pl" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
  tags = local.module_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "nfs_pl_link" {
  name                  = "nfs-plz-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.nfs_pl.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "nfs_pe" {
  name                = "pe-nfs-share"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_subnet_id

  private_service_connection {
    name                           = "nfs-connection"
    private_connection_resource_id = azurerm_storage_account.nfs_sa.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "nfs-plz-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.nfs_pl.id]
  }
  tags = local.module_tags
}