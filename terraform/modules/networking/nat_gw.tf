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

# Attach one NAT Gateway to both private and database subnets
resource "azurerm_subnet_nat_gateway_association" "nat_assoc" {
  for_each = merge(
    { for k, v in azurerm_subnet.private_sub  : k => v },
    { for k, v in azurerm_subnet.database_sub : k => v }
  )

  subnet_id      = each.value.id  
  nat_gateway_id = azurerm_nat_gateway.ngw.id
}

