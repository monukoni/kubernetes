resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "eks_node_group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.eks_subnets[*].id

  instance_types = ["t3.small"]
  disk_size      = 20

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  tags = var.tags
}

resource "aws_iam_role" "eks_node_autoscailing" {
  name = "eks_node_autoscailing"
  assume_role_policy = templatefile(var.autoscailing_role_path, {
    "oidc_arn" : var.openid_connect_arn,
  "oidc_url" : var.openid_connect_url })
  tags = var.tags
}

resource "aws_iam_role_policy" "eks_node_autoscailing" {
  role = aws_iam_role.eks_node_autoscailing.id
  policy = templatefile(var.autoscailing_role_policy_path, {
    "aws_region" : var.region,
    "aws_account_id" : var.aws_account_id,
    "asg_name" : aws_eks_node_group.eks_node_group.resources[0].autoscaling_groups[0].name })
}

