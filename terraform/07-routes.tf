resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_portfolio_vpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.eks_portfolio_nat_gw.id
    }

  tags = merge(tomap({"Name" = "private-route-table"}), var.permanent_tags)

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_portfolio_vpc.id

  route {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.eks_portfolio_igw.id
    }

  tags = merge(tomap({"Name" = "private-route-table"}), var.permanent_tags)

}