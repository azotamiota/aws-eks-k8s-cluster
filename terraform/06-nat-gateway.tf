resource "aws_eip" "nat_elastic_ip" {
  vpc = true
  tags = merge(tomap({"Name" = "nat-elastic-ip"}), var.permanent_tags)

  # tags = {
  #   Name                      = "nat-elastic-ip",
  #   finops_billing_code       = var.finops_billing_code,
  #   servicenow_application_id = var.servicenow_application_id
  # }
}

resource "aws_nat_gateway" "eks_portfolio_nat_gw" {
  allocation_id = aws_eip.nat_elastic_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = merge(tomap({"Name" = "eks_portfolio_nat_gw"}), var.permanent_tags)

  # tags = {
  #   Name                      = "eks_portfolio_nat_gw",
  #   finops_billing_code       = var.finops_billing_code,
  #   servicenow_application_id = var.servicenow_application_id
  # }

  depends_on = [aws_internet_gateway.eks_portfolio_igw]
}