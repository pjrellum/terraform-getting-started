resource "azurerm_resource_group" "rg" {
  name     = "${var.company_name}-${var.project_name}-${var.project_suffix}-${var.environment}"
  location = var.location

  tags = local.tags

}

resource "azurerm_public_ip" "pip" {
  name                = "${var.company_name}-${var.project_name}-pip-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.company_name}-${var.project_name}-nic-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "ip-configuration"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "_%@#.()"
}

resource "azurerm_linux_virtual_machine" "web_server" {
  name                            = "${var.company_name}-${var.project_name}-web-server-${var.environment}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = local.webserver_size[var.environment]
  admin_username                  = "adminuser"
  admin_password                  = random_password.admin_password.result
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  computer_name = "web-server"

  user_data = base64encode(<<EOF
#!/bin/bash
apt-get update
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo '<html><head><title>MegaCorp Web Server ${var.environment}</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">Welcome to ${var.company_name} ${var.environment}!</span></span></p></body></html>' | sudo tee /var/www/html/index.html
EOF
  )

  tags = local.tags
}
