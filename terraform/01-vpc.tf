resource "aws_vpc" "eks_portfolio_vpc" {
  cidr_block = "10.240.0.0/16"
  tags = {
    Name                      = "eks-portfolio-vpc",
    finops_billing_code       = var.finops_billing_code,
    servicenow_application_id = var.servicenow_application_id
  }
}