resource "null_resource" "service_account_aws_ebs_csi_driver_addon" {

  count = lookup(aws_eks_addon.eks_addons, "aws-ebs-csi-driver", null) != null ? 1 : 0

  provisioner "local-exec" {
    command = <<COMMAND
      export KUBECONFIG=${path.root}/output/${var.name}/kubeconfig-${var.name} \
      && kubectl -n kube-system annotate serviceaccount ebs-csi-controller-sa eks.amazonaws.com/role-arn- \
      && kubectl -n kube-system annotate serviceaccount ebs-csi-controller-sa eks.amazonaws.com/role-arn=${aws_iam_role.csi_ebs_role.arn};
      COMMAND
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }
  depends_on = [aws_iam_role.csi_ebs_role]
}
