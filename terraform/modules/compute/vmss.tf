resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "vmss-3tier-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_B2s"
  instances           = 2
  admin_username      = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # cloud-init via custom data
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yml.tpl", {
    resource_group   = var.resource_group_name
    storage_account  = var.storage_account_name
    file_share       = var.fileshare_name
    kv_name          = var.mysqlvault_name
    mysql_server_name = "mysql-server"
    mysql_db_name     = "mysql-db"
    }))
 
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "primary-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.private_subnet_id

      application_gateway_backend_address_pool_ids = [
        var.backend_addr_pool_id
      ]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.module_tags
}
