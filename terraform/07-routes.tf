resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_portfolio_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_portfolio_nat_gw.id
  }

  tags = merge(tomap({ "Name" = "private-route-table" }), var.permanent_tags)

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_portfolio_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_portfolio_igw.id
  }

  tags = merge(tomap({ "Name" = "private-route-table" }), var.permanent_tags)

}

resource "aws_route_table_association" "private" {
  count          = length(var.private-subnets-cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public-subnets-cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}
