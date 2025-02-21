variable "private-subnets-cidr" {
  description = "Private subnets CIDR block"
  type        = list(string)
  default     = ["10.240.0.0/19", "10.240.32.0/19"]
}

variable "public-subnets-cidr" {
  description = "Public subnets CIDR block"
  type        = list(string)
  default     = ["10.240.64.0/19", "10.240.96.0/19"]
}

variable "availability_zones" {
  description = "Availibility zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "permanent_tags" {
  type        = map(string)
  description = "Permanent tags"
}
