resource "aws_eks_cluster" "eks" {
  name     = "${var.name}-eks"
  role_arn = var.eks_role_arn

  upgrade_policy {
    support_type = "STANDARD"
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
  }

  version = "1.36"
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
  name = "${var.name}_oidc"
  assume_role_policy = templatefile(var.oidc_role_path, {
    "oidc_arn" : aws_iam_openid_connect_provider.eks.arn,
  "oidc_url" : aws_iam_openid_connect_provider.eks.url })
  tags = var.tags
}

# resource "aws_iam_policy" "external_secrets_access_policy" {
#   name   = "external_secrets_access_policy"
#   policy = file(var.external_secrets_access_policy_path)
# }

# resource "aws_iam_role" "external_secrets_pod_identity_role" {
#   name = "external_secrets_pod_identity_role"
#   assume_role_policy = templatefile(var.external_secrets_pod_identity_role_path, {
#   "secret_arn" : var.cloudflare_api_key_secret_arn })
#   tags = var.tags
# }

# resource "aws_iam_role_policy_attachment" "external_secrets_pod_identity_role_attach" {
#   role       = aws_iam_role.external_secrets_pod_identity_role.name
#   policy_arn = aws_iam_policy.external_secrets_access_policy.arn
# }

# resource "aws_eks_pod_identity_association" "external_secrets_pod_identity_association" {
#   cluster_name    = aws_eks_cluster.eks.name
#   namespace       = "external-secrets"
#   service_account = "external-secrets"
#   role_arn        = aws_iam_role.external_secrets_pod_identity_role.arn
# }