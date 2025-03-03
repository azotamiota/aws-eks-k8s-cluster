resource "aws_iam_role" "eks_portfolio_nodes_role" {
  name = "eks-portfolio-nodes-role"
  tags = merge(tomap({ "Name" = "eks-portfolio-nodes-role" }), var.permanent_tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "template-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_portfolio_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "template-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_portfolio_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "template-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_portfolio_nodes_role.name
}

# needed by default for EKS but read only
resource "aws_iam_role_policy_attachment" "template-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_portfolio_nodes_role.name
}

# session manager access
resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_portfolio_nodes_role.name
}
