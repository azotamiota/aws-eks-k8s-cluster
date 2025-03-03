resource "aws_eks_node_group" "eks_portfolio_private_nodes" {
  cluster_name      = aws_eks_cluster.eks_portfolio_cluster.name
  node_group_name   = "eks-portfolio-private-nodes"
  node_role_arn     = aws_iam_role.eks_portfolio_nodes_role.arn
  subnet_ids = concat(
    aws_subnet.private_subnet[*].id
  )

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  ami_type = "AL2_ARM_64"
  capacity_type        = "ON_DEMAND"
  force_update_version = true

  launch_template {
    id      = aws_launch_template.workers.id
    version = aws_launch_template.workers.latest_version
  }

  tags = merge(tomap({ "Name" = "eks-portfolio-private-node-group" }), var.permanent_tags)


  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size, tags]
  }

  timeouts {
    update = "180m"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.template-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.template-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.template-AmazonEBSCSIDriverPolicy,
  ]
}
