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
}
