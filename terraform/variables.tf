variable "private-subnets-cidr" {
  description = "Private subnets CIDR block"
  type        = list(string)
}

variable "public-subnets-cidr" {
  description = "Public subnets CIDR block"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availibility zones"
  type        = list(string)
}

variable "permanent_tags" {
  type        = map(string)
  description = "Permanent tags"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}
