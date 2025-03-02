variable "cluster_name" {
  type        = string
  description = "Name to be used on all the EKS Cluster resources as identifier."
}

variable "enable_baseapps" {
  description = "Installation of base apps"
  type        = bool
  default     = false
}

# variable "account_name" {
#   description = "account name"
# }
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs where worker nodes can be created."
}

variable "node_groups" {
  description = "Map of maps of `eks_node_groups` to create. See \"`node_groups` and `node_groups_defaults` keys\" section in README.md for more details"
  type        = any
  default     = {}
}

variable "tags" {
  type = map(any)
}

variable "account_name" {
  type = string
}
variable "node_security_group" {
  type = string
}

variable "cluster_security_group" {
  type = string
}

variable "cluster_endpoint" {
  type        = string
  description = "Endpoint of associated EKS cluster."
  default     = ""
}

variable "cluster_auth_base64" {
  type        = string
  description = "Base64 encoded CA of associated EKS cluster."
  default     = ""
}

variable "rotation_max_unavailable_nodes_number" {
  type        = number
  description = "Desired max number of unavailable worker nodes during node group update"
  default     = 1
}

# variable "rotation_max_unavailable_nodes_percents" {
#   type        = number
#   description = "Desired max number of unavailable worker nodes during node group update"
#   default     = 5
# }
