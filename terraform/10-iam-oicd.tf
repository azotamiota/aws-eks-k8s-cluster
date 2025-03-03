data "tls_certificate" "tls_certificate_cluster" {
  url = aws_eks_cluster.eks_portfolio_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_certificate_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_portfolio_cluster.identity[0].oidc[0].issuer
}
