locals {
  environments = ["tst", "prd"]

  tags = {
    environment = var.environment
    company     = var.company_name
    project     = "${var.company_name}-${var.project_name}"
  }
}
