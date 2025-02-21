# resource "aws_internet_gateway" "eks_portfolio_igw" {
#   vpc_id = module.vpc.vpc_id
#   tags   = merge(tomap({ "Name" = "eks_portfolio_igw" }), var.permanent_tags)
# }
