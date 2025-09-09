# Create Bastion host
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-host"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "bastion-ip-configuration"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = var.bastion_pip_id
  }
  tags = local.module_tags
}