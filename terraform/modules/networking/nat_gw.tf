# NAT Gateway
resource "azurerm_nat_gateway" "ngw" {
  name                = "nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  idle_timeout_in_minutes = 10

  tags = local.module_tags
}

# Associate Nat gw with public IP
resource "azurerm_nat_gateway_public_ip_association" "ngw_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.ngw.id
  public_ip_address_id = azurerm_public_ip.pub_ip_nat.id
}

# Attach the NAT Gateway to subnets
resource "azurerm_subnet_nat_gateway_association" "nat_assoc" {
    for_each       = local.nat_subnet_ids
    subnet_id      = each.value
    nat_gateway_id = azurerm_nat_gateway.ngw.id
}
