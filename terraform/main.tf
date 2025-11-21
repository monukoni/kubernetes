module "networking" {
  source   = "./modules/network"
  name     = var.name
  tags     = var.tags
  vpc_cidr = var.vpc_cidr
  region   = var.region
}

module "iam" {
  source         = "./modules/iam"
  tags           = var.tags
  aws_account_id = data.aws_caller_identity.current.account_id
  region         = var.region
}

module "eks" {
  source         = "./modules/eks"
  admin_user_arn = data.aws_iam_user.root.arn
  eks_role_arn   = module.iam.eks_role_arn
  subnets        = module.networking.eks_private_subnets[*].id
  oidc_role_path = "./policies/oidc-role.json"
}

module "node_group" {
  source                        = "./modules/node_group"
  name                          = var.name
  region                        = var.region
  instance_types                = ["c7i-flex.large"]
  cluster_name                  = module.eks.cluster_name
  eks_subnets                   = module.networking.eks_private_subnets
  openid_connect_arn            = module.eks.openid_connect_arn
  openid_connect_url            = module.eks.openid_connect_url
  eks_node_role_arn             = module.iam.eks_node_role
  aws_account_id                = data.aws_caller_identity.current.account_id
  autoscailing_role_path        = "./policies/autoscailing-role.json"
  autoscailing_role_policy_path = "./policies/autoscailing-role-policy.json"
  ebs_csi_driver_role_path      = "./policies/ebs_csi_driver_role.json"
}

resource "kubernetes_storage_class" "gp2_default" {
  metadata {
    name = "default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  allow_volume_expansion = "true"
  volume_binding_mode    = "WaitForFirstConsumer"
  reclaim_policy         = "Delete"
  parameters = {
    type   = "gp2"
    fsType = "ext4"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  depends_on          = [module.eks]
}

module "consul" {
  source                = "./modules/consul"
  consul_variables_path = "./modules/consul/values.yaml"
  name                  = var.name
  depends_on            = [module.node_group, module.networking, module.iam, module.eks]
}

resource "aws_ecr_repository" "frontend" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  count = terraform.workspace == "default" ? 1 : 0
}

resource "aws_ecr_repository" "backend" {
  name                 = "backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  count = terraform.workspace == "default" ? 1 : 0
}

data "aws_iam_user" "root" {
  user_name = var.admin_user
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}