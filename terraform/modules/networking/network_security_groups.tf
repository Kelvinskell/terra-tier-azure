# Create NSGs
# Public NSG
resource "azurerm_network_security_group" "nsg_public" {
  name                = "nsg-public"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Internet -> App Gateway
  security_rule {
    name                       = "Allow-HTTP-from-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
  name                       = "Allow-AppGW-Infrastructure"
  priority                   = 101
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_ranges    = ["65200-65535"]
  source_address_prefix      = "Internet"
  destination_address_prefix = "*"
}
  tags = local.module_tags
}

# Private NSG
resource "azurerm_network_security_group" "nsg_private" {
  name                = "nsg-private"
  location            = var.location
  resource_group_name = var.resource_group_name

  # App Gateway (in public subnet) -> Flask on 5000
  security_rule {
    name                       = "Allow-AppGW-to-FlaskApp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefixes    = [ for s in azurerm_subnet.public_sub : s.address_prefixes[0] ]
    destination_address_prefix = "*"
  }

  # Bastion -> SSH
  security_rule {
    name                       = "Allow-Bastion-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork" # service tag
    destination_address_prefix = "*"
  }


  tags = local.module_tags
}

# Database NSG
resource "azurerm_network_security_group" "nsg_db" {
  name                = "nsg-db"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Flask App -> DB on 3306
  security_rule {
    name                       = "Allow-FlaskApp-to-DB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefixes    = [ for s in azurerm_subnet.private_sub : s.address_prefixes[0] ]
    destination_address_prefix = "*"
  }

  tags = local.module_tags
}

# Bastion NSG
resource "azurerm_network_security_group" "nsg_bastion" {
  name                = "nsg-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.module_tags

  # ---------- Inbound ----------
  security_rule {
    name                       = "Allow-HTTPS-From-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS-From-GatewayManager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS-From-AzureLoadBalancer"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Bastion-DataPlane-In"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # ---------- Outbound ----------
  security_rule {
    name                       = "Allow-RDP-SSH-Out"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389", "22"]
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Allow-Bastion-DataPlane-Out"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Allow-AzureCloud-443-Out"
    priority                   = 220
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "Allow-Internet-80-Out"
    priority                   = 230
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

# Associate Subnets with their NSGs
resource "azurerm_subnet_network_security_group_association" "assoc_public" {
  for_each = azurerm_subnet.public_sub
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_private" {

  for_each = azurerm_subnet.private_sub
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg_private.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_database" {
  for_each = azurerm_subnet.database_sub
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_bastion" {
  subnet_id                 = azurerm_subnet.bastion_sub.id
  network_security_group_id = azurerm_network_security_group.nsg_bastion.id
}