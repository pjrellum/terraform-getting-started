data "azurerm_subnet" "subnet" {
  name                 = "${var.company_name}-${var.project_name}-subnet-${var.project_suffix}-${var.environment}"
  resource_group_name  = "${var.company_name}-${var.project_name}-network"
  virtual_network_name = "${var.company_name}-${var.project_name}-vnet"
}