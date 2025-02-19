resource "aws_vpc" "eks_portfolio_vpc" {
  cidr_block = "10.240.0.0/16"
  tags       = merge(tomap({ "Name" = "eks-portfolio-vpc" }), var.permanent_tags)
}
