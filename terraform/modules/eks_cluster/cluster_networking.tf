# resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
#   vpc_id     = var.vpc_id
#   cidr_block = var.eks_additional_vpc_cidr
# }

# resource "aws_subnet" "private" {
#   count = length(var.private_subnets)

#   vpc_id            = var.vpc_id
#   cidr_block        = cidrsubnet(var.eks_additional_vpc_cidr,var.newbits,var.private_subnets[count.index])
#   availability_zone = element(var.cluster_azs, count.index)

# tags = merge(var.tags,
#   map("Name", format("%s.%s.%s", element(var.cluster_azs, count.index), var.name, var.k8s_domain)),
#   "kubernetes.io/cluster/ad4" = "shared"
# )

resource "aws_subnet" "private-1a" {

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.eks_additional_vpc_cidr, var.newbits, var.private_subnets[0])
  availability_zone = element(var.cluster_azs, 0)

  tags = merge(var.tags,
    { Name = format("%s-%s", element(var.cluster_azs, 0), var.cluster_name) },
    { format("%s%s", "kubernetes.io/cluster/", var.cluster_name) = "shared" }
  )

  provisioner "local-exec" {
    when       = destroy
    command    = "../../../../../jenkins/scripts/tidy-up-leftover-eni.sh ${self.id}"
    on_failure = continue
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "private-1b" {

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.eks_additional_vpc_cidr, var.newbits, var.private_subnets[1])
  availability_zone = element(var.cluster_azs, 1)

  tags = merge(var.tags,
    { Name = format("%s-%s", element(var.cluster_azs, 1), var.cluster_name) },
    { format("%s%s", "kubernetes.io/cluster/", var.cluster_name) = "shared" }
  )

  provisioner "local-exec" {
    when       = destroy
    command    = "../../../../../jenkins/scripts/tidy-up-leftover-eni.sh ${self.id}"
    on_failure = continue
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = element(var.aws_route_tables, 0)
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private-1b.id
  route_table_id = element(var.aws_route_tables, 1)
}

resource "local_file" "eniplugins" {
  count = var.enable_kube2iam ? 1 : 0

  content  = local.eniplugins
  filename = "${path.root}/output/${var.name}/eniplugins.yaml"

  depends_on = [
    null_resource.output,
    aws_security_group.cluster,
    aws_eks_cluster.eks_portfolio_cluster,
  ]
}

resource "null_resource" "eniplugins" {
  count = var.enable_kube2iam ? 1 : 0

  provisioner "local-exec" {
    command = "../../../../../jenkins/scripts/install_eniplugins.sh ${var.name}"
  }

  # triggers = {
  #   always_run = "${timestamp()}"
  # }

  depends_on = [local_file.eniplugins,
    aws_eks_cluster.eks_portfolio_cluster,
    local_file.kubeconfig,
    null_resource.aws_auth
  ]
}

resource "null_resource" "service_account_cni_addon" {

  count = lookup(aws_eks_addon.eks_addons, "vpc-cni", null) != null ? 1 : 0

  provisioner "local-exec" {
    command = "../../../../../jenkins/scripts/service_account_cni_addon.sh ${var.name} ${aws_iam_role.cni_role.arn}"
  }

  # triggers = {
  #   always_run = "${timestamp()}"
  # }

  depends_on = [aws_iam_role.cni_role,
    local_file.eniplugins,
    null_resource.eniplugins,
    local_file.kubeconfig
  ]
}


resource "aws_ec2_tag" "tag_existing_networks" {
  for_each    = toset(var.subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.name}"
  value       = "shared"
}
