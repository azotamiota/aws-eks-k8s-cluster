# Cluster Role
resource "aws_iam_role" "cluster" {
  name = "EKSClusterRole-${var.name}"

  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role.json
  permissions_boundary  = var.permissions_boundary
  force_detach_policies = true
}

data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Node Role
resource "aws_iam_role" "node" {
  name = "EKSNodeRole-${var.name}"

  assume_role_policy    = data.aws_iam_policy_document.node_assume_role.json
  permissions_boundary  = var.permissions_boundary
  force_detach_policies = true
}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = var.name
  role = aws_iam_role.node.name
}


# Role for cni

data "tls_certificate" "tls_certificate_cluster" {
  url = aws_eks_cluster.eks_portfolio_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_certificate_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_portfolio_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "cni_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.provider.arn]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "csi_ebs_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cni_role" {
  assume_role_policy = data.aws_iam_policy_document.cni_role_policy.json
  name               = format("%s-vpc-cni-role", aws_eks_cluster.eks_portfolio_cluster.name)
}

resource "aws_iam_role_policy_attachment" "cni_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cni_role.name
}

resource "aws_iam_role" "csi_ebs_role" {
  assume_role_policy = data.aws_iam_policy_document.csi_ebs_role_policy.json
  name               = format("%s-csi-ebs-role", aws_eks_cluster.eks_portfolio_cluster.name)
}

resource "aws_iam_role_policy_attachment" "csi_ebs_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.csi_ebs_role.name
}
