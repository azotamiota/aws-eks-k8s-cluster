# Cluster Security Group
resource "aws_security_group" "cluster" {
  name        = "${var.name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags,
    { "Name" = format("%s-cluster", var.name) },
  { "karpenter.sh/discovery" = var.name })
}

resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  count = length(flatten([var.workstation_cidr])) != 0 ? 1 : 0

  description       = "Allow workstation to communicate with the cluster API Server"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = flatten([var.workstation_cidr])
}

# Node Security Group
resource "aws_security_group" "node" {
  name        = "${var.name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    { Name = "${var.name}-node" },
    { format("%s%s", "kubernetes.io/cluster/", var.name) = "owned" },
    { "karpenter.sh/discovery" = var.name }
  )

}

resource "aws_security_group_rule" "node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_ingress_self" {
  description              = "Allow cluster sg to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_ingress_cluster_https" {
  description              = "Allow incoming https connections from the EKS masters security group"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "api-access" {
  description       = "Allow users to communicate with the cluster API Server"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["10.240.0.0/16"]
}

resource "aws_security_group_rule" "cni_vpc" {
  description       = "Allow cni network to talk to cluster"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["10.240.0.0/16"]
}
