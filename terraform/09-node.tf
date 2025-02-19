# resource "aws_iam_role" "eks_portfolio_nodes_role" {
#   name = "eks-portfolio-nodes-role"
#   tags = merge(tomap({ "Name" = "eks-portfolio-nodes-role" }), var.permanent_tags)

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# # IAM policy attachment to nodegroup
# resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_portfolio_nodes_role.name
# }

# resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_portfolio_nodes_role.name
# }

# resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_portfolio_nodes_role.name
# }


# # aws node group

# resource "aws_eks_node_group" "eks_portfolio_private_nodes" {
#   #   ami_type        = "AL2_ARM_64"
#   cluster_name    = aws_eks_cluster.eks_portfolio_cluster.name
#   node_group_name = "eks-portfolio-private-nodes"
#   node_role_arn   = aws_iam_role.eks_portfolio_nodes_role.arn
#   tags            = merge(tomap({ "Name" = "eks-portfolio-private-nodes" }), var.permanent_tags)

#   subnet_ids = concat(
#     aws_subnet.private_subnet[*].id
#   )

#   capacity_type  = "ON_DEMAND"
#   instance_types = ["t3.micro"]

#   scaling_config {
#     desired_size = 2
#     max_size     = 10
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   #   labels = {
#   #     node = "kubenode02"
#   #   }

#   # taint {
#   #   key    = "team"
#   #   value  = "devops"
#   #   effect = "NO_SCHEDULE"
#   # }

#   # launch_template {
#   #   name    = aws_launch_template.eks-with-disks.name
#   #   version = aws_launch_template.eks-with-disks.latest_version
#   # }

#   depends_on = [
#     aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
#   ]
# }

# # launch template if required

# # resource "aws_launch_template" "eks-with-disks" {
# #   name = "eks-with-disks"

# #   key_name = "local-provisioner"

# #   block_device_mappings {
# #     device_name = "/dev/xvdb"

# #     ebs {
# #       volume_size = 50
# #       volume_type = "gp2"
# #     }
# #   }
# # }
