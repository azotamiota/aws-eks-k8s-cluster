output "nodegroup_ids" {
  value = try(aws_eks_node_group.template["1"].id, "")
}

output "iam_role_arn" {
  value = aws_iam_role.template.arn
}
