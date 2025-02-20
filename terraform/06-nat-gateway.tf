resource "aws_eip" "nat_elastic_ip" {
  domain = "vpc"
  tags   = merge(tomap({ "Name" = "nat-elastic-ip" }), var.permanent_tags)
}

resource "aws_nat_gateway" "eks_portfolio_nat_gw" {
  allocation_id = aws_eip.nat_elastic_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags          = merge(tomap({ "Name" = "eks_portfolio_nat_gw" }), var.permanent_tags)

  depends_on = [aws_internet_gateway.eks_portfolio_igw]
}
