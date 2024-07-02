variable "environment" {
  description = "The environment in which the resources will be created."
  type        = string
  default = "svc"
}

variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
  default     = "West Europe"
}

variable "company_name" {
  description = "The name of the company."
  type        = string
  default     = "megacorp"
}

variable "project_name" {
  description = "The name of the project."
  type        = string

  default = "exercise-2"
}
