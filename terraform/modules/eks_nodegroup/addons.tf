
# Calico
resource "null_resource" "push_secrets" {

  provisioner "local-exec" {
    command = <<COMMAND
    aws eks update-kubeconfig --region eu-west-2 --name ${var.cluster_name} \
    && pwd \
    && cd ../../../../../dps-secrets/ \
    && ./utils/push-all-secrets.sh ${var.cluster_name}
    COMMAND
  }
  # uncomment to force redeploy after first run
  # triggers = {
  #     timestamp = timestamp()
  #   }
  depends_on = [
    aws_eks_node_group.template
  ]
}
resource "null_resource" "k8_base_apps" {
  count = var.enable_baseapps ? 1 : 0

  provisioner "local-exec" {
    command = <<COMMAND
    cd ../../../../../ \
    && ./jenkins/scripts/k8_base_apps.sh ${var.cluster_name}
    COMMAND
  }
  # Leaving here for legacy - uncomment triggers to force redeploy after first run
  # triggers = {
  #     timestamp = timestamp()
  #   }
  depends_on = [
    null_resource.push_secrets,
    aws_eks_node_group.template
  ]
}

# Temporarily suspend AZRebalance process for ANT1 auto-scaling group
data "aws_autoscaling_groups" "this" {
  filter {
    name   = "tag:k8s.io/cluster-autoscaler/enabled"
    values = ["true"]
  }
  filter {
    name   = "tag:k8s.io/cluster-autoscaler/${var.cluster_name}"
    values = ["owned"]
  }
  filter {
    name   = "tag:eks:cluster-name"
    values = ["ant1"]
  }
}
resource "null_resource" "disable_AZRebalacing" {
  # count = var.dizable_AZRebalance ? 1 : 0
  for_each = toset(data.aws_autoscaling_groups.this.names)
  provisioner "local-exec" {
    command = <<COMMAND
    set -e
    aws autoscaling suspend-processes \
      --auto-scaling-group-name ${each.key} \
      --scaling-process AZRebalance
    COMMAND
  }
  triggers = {
    timestamp = timestamp()
  }
  # Runs only when auto-scaling group name change
  # triggers = {
  #     value = each.key
  #   }
}
