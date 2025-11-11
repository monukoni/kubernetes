module "networking" {
  source   = "./terraform/network"
  name     = var.name
  tags     = var.tags
  vpc_cidr = var.vpc_cidr
  region   = var.region
}

module "iam" {
  source         = "./terraform/iam"
  tags           = var.tags
  aws_account_id = data.aws_caller_identity.current.account_id
  region         = var.region
}

module "eks" {
  source         = "./terraform/eks"
  admin_user_arn = data.aws_iam_user.root.arn
  eks_role_arn   = module.iam.eks_role_arn
  subnets        = module.networking.eks_private_subnets[*].id
  oidc_role_path = "./terraform/policies/oidc-role.json"
}

module "node_group" {
  source                        = "./terraform/node_group"
  name                          = var.name
  region                        = var.region
  cluster_name                  = module.eks.cluster_name
  eks_subnets                   = module.networking.eks_private_subnets
  openid_connect_arn            = module.eks.openid_connect_arn
  openid_connect_url            = module.eks.openid_connect_url
  eks_node_role_arn             = module.iam.eks_node_role
  aws_account_id                = data.aws_caller_identity.current.account_id
  autoscailing_role_path        = "./terraform/policies/autoscailing-role.json"
  autoscailing_role_policy_path = "./terraform/policies/autoscailing-role-policy.json"
}

data "aws_iam_user" "root" {
  user_name = var.admin_user
}

data "aws_caller_identity" "current" {}