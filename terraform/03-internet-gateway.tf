resource "aws_internet_gateway" "eks_portfolio_igw" {
  vpc_id = aws_vpc.eks_portfolio_vpc.id
  tags = merge(tomap({"Name" = "eks_portfolio_igw"}), var.permanent_tags)

  # tags = {
  #   Name                      = "eks_portfolio_igw",
  #   finops_billing_code       = var.finops_billing_code,
  #   servicenow_application_id = var.servicenow_application_id
  # }
}