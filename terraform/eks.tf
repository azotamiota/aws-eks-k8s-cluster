module "eks" {
  source = "./modules/eks_cluster"

  name            = "eks_portfolio_cluster"
  account_id      = var.account_id
  cluster_name    = "eks_portfolio_cluster"
  vpc_id          = aws_vpc.eks_portfolio_vpc.id
  private_subnets = concat(aws_subnet.private_subnet[*].id)
  # eks_additional_vpc_cidr = data.terraform_remote_state.account.outputs.eks_additional_vpc_cidr_1
  subnet_ids = concat(
    aws_subnet.public_subnet[*].id,
    aws_subnet.private_subnet[*].id
  )
  cluster_azs = var.availability_zones
  newbits     = 4

  eks_version      = "1.30"
  aws_route_tables = [aws_route_table.public.id, aws_route_table.private.id]
  enable_kubectl   = true
  enable_kube2iam  = false
  enable_dashboard = false
  enable_calico    = false

  tags = merge(tomap({ "Name" = "eks-portfolio-eks-cluster" }), var.permanent_tags)

  eks_addons = [
    {
      name    = "coredns"
      version = "v1.11.3-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.19.0-eksbuild.1"
    },
    {
      name    = "kube-proxy"
      version = "v1.30.6-eksbuild.3"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.35.0-eksbuild.1"
    },
    {
      name    = "eks-pod-identity-agent"
      version = "v1.3.4-eksbuild.1"
    }
  ]

  # More details here:
  # https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
  aws_auth = <<AWSAUTH
    - rolearn: arn:aws:iam::${var.account_id}:role/PlatformAdminAcrossAccounts
      username: kubernetes-dps
      groups:
      - system:masters
    - rolearn: arn:aws:iam::${var.account_id}:role/eks-node-group-eks_portfolio_cluster
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::${var.account_id}:role/"AWSReservedSSO_Org-Kubernetes-Admin_0883db18b19c9d0f"}
      username: adminuser:{{SessionName}}
      groups:
      - system:masters
AWSAUTH
}

module "node_group" {
  source = "./modules/eks_nodegroup"
  subnet_ids = concat(
    aws_subnet.public_subnet[*].id,
    aws_subnet.private_subnet[*].id
  )
  cluster_name = module.eks.name
  node_groups = {
    1 = {
      name             = "eks-portfolio-eks-cluster-worker"
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 1
      ami_type         = "AL2_x86_64",
      ami_id           = "", # you need specify either ami_id or version
      disk_size        = 20,
      disk_type        = "gp3",
      additional_disk = [
        {
          name      = "/dev/xvdb",
          disk_size = 5,
          disk_type = "gp3",
        },
        {
          name      = "/dev/xvdc",
          disk_size = 5,
          disk_type = "gp3",
        }
      ],                                      # additional disk for kubelet and containerd (/var/lib/kubelet/pods/, /var/lib/containerd/)
      version            = "1.30",            # you need specify either 'ami_id' or 'version'
      release_version    = "1.30.6-20241121", # https://github.com/awslabs/amazon-eks-ami/blob/master/CHANGELOG.md
      instance_types     = "t4g.small"        #["t3.xlarge"] changing to single entry for launch templates
      enable_monitoring  = true
      pre_userdata       = ""
      kubelet_extra_args = ""
      container_runtime  = "containerd"
      #capacity_type  = "SPOT"   #   not tested
      # k8s_labels = {
      #   Environment = "test"
      #   GithubRepo  = "terraform-aws-eks"
      #   GithubOrg   = "terraform-aws-modules"
      # }
      additional_tags = {
        Name = "eks-portfolio-eks-cluster-worker"
      }
    }
    2 = {
      name             = "eks-portfolio-eks-cluster-worker-2"
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 1
      ami_type         = "AL2_x86_64",
      ami_id           = "", # you need specify either ami_id or version
      disk_size        = 20,
      disk_type        = "gp3",
      additional_disk = [
        {
          name      = "/dev/xvdb",
          disk_size = 5,
          disk_type = "gp3",
        },
        {
          name      = "/dev/xvdc",
          disk_size = 5,
          disk_type = "gp3",
        }
      ],                                      # additional disk for kubelet and containerd (/var/lib/kubelet/pods/, /var/lib/containerd/)
      version            = "1.30",            # you need specify either 'ami_id' or 'version'
      release_version    = "1.30.6-20241121", # https://github.com/awslabs/amazon-eks-ami/blob/master/CHANGELOG.md
      instance_types     = "t4g.small"        #["t3.xlarge"] changing to single entry for launch templates
      enable_monitoring  = true
      pre_userdata       = ""
      kubelet_extra_args = ""
      container_runtime  = "containerd"
      #capacity_type  = "SPOT"   #   not tested
      # k8s_labels = {
      #   Environment = "test"
      #   GithubRepo  = "terraform-aws-eks"
      #   GithubOrg   = "terraform-aws-modules"
      # }
      additional_tags = {
        Name = "an3-worker"
      }
    }
  }
  tags                   = merge(tomap({ "Name" = "eks-portfolio-eks-cluster" }), var.permanent_tags)
  account_name           = "ad"
  node_security_group    = module.eks.node_security_group
  cluster_security_group = module.eks.cluster_security_group
}
