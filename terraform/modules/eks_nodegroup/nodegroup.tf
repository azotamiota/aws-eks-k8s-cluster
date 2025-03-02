resource "aws_eks_node_group" "template" {
  for_each        = var.node_groups
  cluster_name    = var.cluster_name
  node_group_name = join("-", [var.cluster_name, each.value["name"]])
  node_role_arn   = aws_iam_role.template.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = each.value["desired_capacity"]
    max_size     = each.value["max_capacity"]
    min_size     = each.value["min_capacity"]
  }

  update_config {
    max_unavailable = var.rotation_max_unavailable_nodes_number
    #max_unavailable_percentage = var.rotation_max_unavailable_nodes_percents
  }

  ami_type = each.value["ami_type"] == "" ? null : each.value["ami_type"]
  # disk_size       = each.value["disk_size"] removed launch template
  # instance_types  = each.value["instance_types"] removed launch template
  capacity_type        = "ON_DEMAND"
  force_update_version = true
  version              = each.value["version"] == "" ? null : each.value["version"]
  release_version      = each.value["release_version"] == "" ? null : each.value["release_version"]

  launch_template {
    id      = aws_launch_template.workers[each.key].id
    version = aws_launch_template.workers[each.key].latest_version
  }

  tags = merge(var.tags, each.value["additional_tags"])

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size, tags]
  }

  timeouts {
    update = "180m"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.template-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.template-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.template-AmazonEBSCSIDriverPolicy,
    aws_iam_role_policy_attachment.eks_additional_policy,
    aws_iam_role_policy_attachment.kube2iam_policy_eks,
  ]
}

resource "null_resource" "enable_asg_metrics_collection" {
  for_each = aws_eks_node_group.template

  provisioner "local-exec" {
    command = <<EOT
      aws autoscaling enable-metrics-collection --auto-scaling-group-name ${each.value.resources[0].autoscaling_groups[0].name} --granularity "1Minute"
    EOT
  }

  # triggers = {
  #   always_run = "${timestamp()}"
  # }

  depends_on = [aws_eks_node_group.template]
}
