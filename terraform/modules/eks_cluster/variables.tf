variable "name" {
  type        = string
  description = "Name to be used on all the EKS Cluster resources as identifier."
}

variable "eks_version" {
  default     = "1.19"
  description = "Kubernetes version to use for the cluster."
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where to create the cluster resources."
}

variable "eks_additional_vpc_cidr" {
  description = "Additional cidr range to use for eks cluster has to be unique to account"
  default     = false
  type        = string
}

variable "cluster_azs" {
  type        = list(any)
  description = "List of AWS AZs in use for cluster subnets"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "subnet_ids" {
  default     = []
  description = "A list of VPC subnet IDs which the cluster uses."
  type        = list(string)
}

variable "private_subnets" {
  type        = list(any)
  description = "List of private subnet CIDRs"
}

variable "newbits" {
  description = "number of bits to increment the cidr over the vpc_cidr"
  type        = number
}

variable "workstation_cidr" {
  default     = []
  description = "CIDR blocks from which to allow inbound traffic to the Kubernetes control plane."
  type        = list(string)
}

variable "enable_kubectl" {
  default     = false
  description = "When enabled, it will merge the cluster's configuration with the one located in ~/.kube/config."
  type        = bool
}

variable "enable_dashboard" {
  default     = false
  description = "When enabled, it will install the Kubernetes Dashboard."
  type        = bool
}

variable "enable_calico" {
  default     = false
  description = "When enabled, it will install Calico for network policy support."
  type        = bool
}

variable "enable_kube2iam" {
  default     = false
  description = "When enabled, it will install Kube2IAM to support assigning IAM roles to Pods."
  type        = bool
}

variable "aws_auth" {
  default     = ""
  description = "Grant additional AWS users or roles the ability to interact with the EKS cluster."
  type        = string
}

variable "permissions_boundary" {
  default     = ""
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  type        = string
}

variable "cluster_private_access" {
  default     = true
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
}

variable "cluster_public_access" {
  default     = false
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
}

# variable "account_name" {
#   description = "account name"
#   type        = string
# }

variable "account_id" {
  description = "account id"
  type        = string
}

variable "cluster_name" {
  description = "cluster name"
  type        = string
}

variable "aws_route_tables" {
  type        = list(string)
  description = "list of route tables for private vlans"
}

variable "tags" {
  type = map(any)
}

variable "pipeline" {
  type    = bool
  default = true
}

variable "eks_addons" {
  type = list(object({
    name    = string
    version = string
  }))
}

variable "kubeconfig_version" {
  default     = "v1beta1"
  description = "kubconfig version to use for the cluster."
  type        = string
}
