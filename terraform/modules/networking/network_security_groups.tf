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
    source_address_prefix      = azurerm_subnet.public_subnet.address_prefixes[0]
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
    source_address_prefix      = "AzureBastion" # service tag
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
    source_address_prefix      = azurerm_subnet.private_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }

  tags = local.module_tags
}

# Bastion NSG
resource "azurerm_network_security_group" "nsg_bastion" {
  name                = "nsg-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Associate Subnets with their NSGs
resource "azurerm_subnet_network_security_group_association" "assoc_public" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_private" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_private.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_database" {
  subnet_id                 = azurerm_subnet.database_sub.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_bastion" {
  subnet_id                 = azurerm_subnet.bastion_sub.id
  network_security_group_id = azurerm_network_security_group.nsg_bastion.id
}