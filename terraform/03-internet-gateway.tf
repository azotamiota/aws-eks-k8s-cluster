resource "aws_internet_gateway" "eks_portfolio_igw" {
  vpc_id = aws_vpc.eks_portfolio_vpc.id
  tags   = merge(tomap({ "Name" = "eks_portfolio_igw" }), var.permanent_tags)
}
