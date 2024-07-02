locals {
  webserver_size = {
    tst = "Standard_B1s"
    prd = "Standard_B2s"
  }

  tags = {
    environment = var.environment
    company     = var.company_name
    project     = "${var.company_name}-${var.project_name}"
  }
}
