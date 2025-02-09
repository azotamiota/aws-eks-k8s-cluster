variable "private-subnets-cidr" {
  description = "Private subnets CIDR block"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availibility zones"
  type        = list(string)
}