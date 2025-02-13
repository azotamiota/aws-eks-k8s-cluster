resource "aws_eip" "nat_elastic_ip" {
  vpc = true

  tags = {
    Name                      = "nat-elastic-ip",
    finops_billing_code       = var.finops_billing_code,
    servicenow_application_id = var.servicenow_application_id
  }
}

resource "aws_nat_gateway" "eks_portfolio_nat_gw" {
  allocation_id = aws_eip.nat_elastic_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name                      = "eks_portfolio_nat_gw",
    finops_billing_code       = var.finops_billing_code,
    servicenow_application_id = var.servicenow_application_id
  }

  depends_on = [aws_internet_gateway.eks_portfolio_igw]
}