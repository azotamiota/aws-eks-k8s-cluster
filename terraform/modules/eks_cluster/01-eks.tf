
# failing as already exists needs deleteing cluster to look at logic

# resource "aws_cloudwatch_log_group" "eks_cluster" {
#   name              = "/aws/eks/${var.name}/cluster"
#   retention_in_days = 7
# }

resource "aws_eks_cluster" "eks_portfolio_cluster" {
  name                      = var.cluster_name
  version                   = var.eks_version
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = flatten([var.subnet_ids])
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = var.cluster_private_access
    endpoint_public_access  = var.cluster_public_access
  }

  kubernetes_network_config {
    service_ipv4_cidr = "192.168.0.0/16"
  }

  tags = merge(var.tags)

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_route_table_association.private_1a,
    aws_route_table_association.private_1b,
  ]
}

resource "aws_eks_addon" "eks_addons" {
  for_each                    = { for addon in var.eks_addons : addon.name => addon }
  cluster_name                = aws_eks_cluster.eks_portfolio_cluster.name
  addon_name                  = each.value.name
  addon_version               = each.value.version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
  configuration_values        = each.value.name == "vpc-cni" ? "{\"env\": {\"AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG\": \"true\", \"ENI_CONFIG_LABEL_DEF\": \"topology.kubernetes.io/zone\"}}" : null
  service_account_role_arn    = each.value.name == "vpc-cni" ? "arn:aws:iam::${var.account_id}:role/${var.name}-vpc-cni-role" : (each.value.name == "aws-ebs-csi-driver" ? "arn:aws:iam::${var.account_id}:role/${var.name}-csi-ebs-role" : null)
}
