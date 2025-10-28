resource "aws_eks_cluster" "eks" {
  name = "eks"
  role_arn = aws_iam_role.eks-role.arn

  upgrade_policy {
    support_type = "STANDARD"
  }

  access_config {
    authentication_mode = "API"
  }

  kubernetes_network_config {
    ip_family = "ipv4"
    service_ipv4_cidr = "10.100.0.0/16"
  }

  version  = "1.33"
  vpc_config {
    subnet_ids = aws_subnet.eks_subnets[*].id
    endpoint_private_access = true
    endpoint_public_access = true
    
  }

  depends_on = [ aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy ]
}

resource "aws_iam_role" "eks-role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_eks_access_entry" "root-access" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = data.aws_iam_user.root.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = data.aws_iam_user.root.arn

  access_scope {
    type       = "cluster"
  }
}

resource "aws_eks_access_policy_association" "cluster-admin" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_user.root.arn

  access_scope {
    type       = "cluster"
  }
}


data "aws_iam_user" "root" {
    user_name = "ADMIN"
}