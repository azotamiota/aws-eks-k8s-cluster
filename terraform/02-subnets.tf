resource "aws_subnet" "private_subnet" {
  count             = length(var.private-subnets-cidr)
  cidr_block        = element(var.private-subnets-cidr, count.index)
  vpc_id            = aws_vpc.eks_portfolio_vpc.id
  availability_zone = element(var.availability_zones, count.index)
  tags = merge(tomap({"Name" = format("private-subnet-%s", count.index)}), var.permanent_tags)
  # tags = {
  #   Name = format("private-subnet-%s", count.index),
  #   # "kubernetes.io/role/internal-elb" = "1",
  #   # "kubernetes.io/cluster/demo"      = "owned",
  #   finops_billing_code       = var.finops_billing_code,
  #   servicenow_application_id = var.servicenow_application_id,
  #   project                   = "eks-portfolio"

  # }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public-subnets-cidr)
  cidr_block              = element(var.public-subnets-cidr, count.index)
  vpc_id                  = aws_vpc.eks_portfolio_vpc.id
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = merge(tomap({"Name" = format("public-subnet-%s", count.index)}), var.permanent_tags)

  # tags = {
  #   Name = format("public-subnet-%s", count.index),
  #   # "kubernetes.io/role/internal-elb" = "1",
  #   # "kubernetes.io/cluster/demo"      = "owned",
  #   finops_billing_code       = var.finops_billing_code,
  #   servicenow_application_id = var.servicenow_application_id,
  # }
}