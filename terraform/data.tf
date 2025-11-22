data "aws_iam_user" "root" {
  user_name = var.admin_user
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}