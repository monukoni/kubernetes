resource "aws_eks_cluster" "eks" {
  name     = "eks"
  role_arn = var.eks_role_arn

  upgrade_policy {
    support_type = "STANDARD"
  }

  access_config {
    authentication_mode = "API"
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
  }

  version = "1.33"
  vpc_config {
    subnet_ids              = var.subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = var.tags
}


resource "aws_eks_access_entry" "root_access" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.admin_user_arn
  type          = "STANDARD"
  tags          = var.tags
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = var.admin_user_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.admin_user_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10df6"]
}



resource "aws_iam_role" "oidc" {
  name = "oidc"
  assume_role_policy = templatefile(var.oidc_role_path, {
    "oidc_arn" : aws_iam_openid_connect_provider.eks.arn,
  "oidc_url" : aws_iam_openid_connect_provider.eks.url })
  tags = var.tags
}
