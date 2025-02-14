# IAM role for eks

resource "aws_iam_role" "eks_portfolio_role" {
  name = "eks-portfolio-role"
  tags = merge(tomap({ "Name" = "eks-portfolio-role" }), var.permanent_tags)


  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_portfolio_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_portfolio_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks_portfolio_cluster" {
  name     = "eks_portfolio_cluster"
  role_arn = aws_iam_role.eks_portfolio_role.arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public_subnet[*].id,
      aws_subnet.private_subnet[*].id
    )
  }

  depends_on = [aws_iam_role_policy_attachment.eks_portfolio_cluster_AmazonEKSClusterPolicy]
}
