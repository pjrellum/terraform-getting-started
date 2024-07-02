resource "azurerm_resource_group" "rg" {
  name     = "${var.company_name}-${var.project_name}-network"
  location = var.location

  tags = local.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.company_name}-${var.project_name}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in local.all_subnets : subnet.name => subnet }

  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "public" {
  for_each = toset(local.environments)

  name                = "${var.company_name}-${var.project_name}-nsg-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  dynamic "security_rule" {
    for_each = local.security_rules[each.key]

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  for_each = { for subnet in local.all_subnets : subnet.name => subnet }

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.public[each.value.environment].id
}
