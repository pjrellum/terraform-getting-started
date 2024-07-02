locals {
  subnets = [
    {
      name = "daniel",
      address_prefixes = {
        tst = ["10.0.1.0/25"]
        prd = ["10.0.1.128/25"]
      }
    },
    {
      name = "julius",
      address_prefixes = {
        tst = ["10.0.2.0/25"]
        prd = ["10.0.2.128/25"]
      }
    },
    {
      name = "mark",
      address_prefixes = {
        tst = ["10.0.3.0/25"]
        prd = ["10.0.3.128/25"]
      }
    },
    {
      name = "matthijs",
      address_prefixes = {
        tst = ["10.0.4.0/25"]
        prd = ["10.0.4.128/25"]
      }
    },
    {
      name = "philip-jan",
      address_prefixes = {
        tst = ["10.0.5.0/25"]
        prd = ["10.0.5.128/25"]
      }
    },
    {
      name = "symen",
      address_prefixes = {
        tst = ["10.0.6.0/25"]
        prd = ["10.0.6.128/25"]
      }
    },
    {
      name = "paul",
      address_prefixes = {
        tst = ["10.0.7.0/25"]
        prd = ["10.0.7.128/25"]
      }
    }
  ]

  all_subnets = flatten([
    for subnet in local.subnets : [
      for environment, address_prefix in subnet.address_prefixes : {
        name             = "${var.company_name}-${var.project_name}-subnet-${subnet.name}-${environment}"
        environment      = environment
        address_prefixes = address_prefix
      }
    ]
  ])

  environments = ["tst", "prd"]

  security_rules_all_environments = {
    http = {
      name                       = "HTTP"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    https = {
      name                       = "HTTPS"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  security_rules_dev_test = {
    ssh = {
      name                       = "SSH"
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  security_rules = {
    tst = merge(local.security_rules_all_environments, local.security_rules_dev_test)
    prd = local.security_rules_all_environments
  }

  tags = {
    environment = var.environment
    company     = var.company_name
    project     = "${var.company_name}-${var.project_name}"
  }
}
