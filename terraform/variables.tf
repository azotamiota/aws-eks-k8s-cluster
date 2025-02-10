variable "private-subnets-cidr" {
  description = "Private subnets CIDR block"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availibility zones"
  type        = list(string)
}

variable "finops_billing_code" {
  description = "Required finops code"
  type        = string
}

variable "servicenow_application_id" {
  description = "Required finops code"
  type        = string
}