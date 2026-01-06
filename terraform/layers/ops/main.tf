module "networking" {
  source   = "../../modules/network"
  name     = var.name
  tags     = var.tags
  vpc_cidr = var.vpc_cidr
}

module "iam" {
  source         = "../../modules/iam"
  name           = var.name
  tags           = var.tags
}

module "eks" {
  source         = "../../modules/eks"
  name           = var.name
  admin_user_arn = data.aws_iam_user.root.arn
  eks_role_arn   = module.iam.eks_role_arn
  subnets        = module.networking.eks_private_subnets[*].id
  oidc_role_path = "../../policies/oidc-role.json"
}

module "node_group" {
  source                        = "../../modules/node_group"
  name                          = var.name
  region                        = var.region
  instance_types                = ["c7i-flex.large"]
  cluster_name                  = module.eks.cluster_name
  eks_subnets                   = module.networking.eks_private_subnets
  openid_connect_arn            = module.eks.openid_connect_arn
  openid_connect_url            = module.eks.openid_connect_url
  eks_node_role_arn             = module.iam.eks_node_role_arn
  aws_account_id                = data.aws_caller_identity.current.account_id
  autoscailing_role_path        = "../../policies/autoscailing-role.json"
  autoscailing_role_policy_path = "../../policies/autoscailing-role-policy.json"
  ebs_csi_driver_role_path      = "../../policies/ebs_csi_driver_role.json"
}

resource "aws_eks_access_entry" "github_action" {
  cluster_name  = module.eks.cluster_name
  principal_arn = data.aws_iam_role.github_actions_OIDC.arn
}

resource "aws_eks_access_policy_association" "gha_tf_eks_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.github_action.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}


resource "kubernetes_annotations" "gp2_default" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "true"
  }
  depends_on = [module.eks]
}
