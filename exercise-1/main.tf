resource "azurerm_resource_group" "rg" {
  name     = "exercise-1-paul"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "exercise-1-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "exercise-1-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "public" {
  name                = "exercise-1-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  subnet_id           = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_public_ip" "pip" {
  name                = "exercise-1-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                      = "exercise-1-nic"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "ip-configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_linux_virtual_machine" "web_server" {
  name                = "web-server"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = random_password.admin_password.result
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
  computer_name  = "web-server"

  user_data = base64encode(<<EOF
#!/bin/bash
apt-get update
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo '<html><head><title>My Awesome Web Server</title></head><body style="background-color:#1F778D"><p style="text-align: center;"><span style="color:#FFFFFF;"><span style="font-size:28px;">You did it! Have a &#9749;</span></span></p></body></html>' | sudo tee /var/www/html/index.html
EOF
)
}
