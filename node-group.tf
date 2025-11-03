resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks_node_group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.eks_subnets[*].id
  
  instance_types = [ "t3.small" ]
  disk_size = 20

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node-AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks
  ]
  tags = var.tags
}

resource "aws_iam_role" "oidc" {
  name = "oidc"
  assume_role_policy = templatefile("oidc-role.json", { 
    "oidc_arn": aws_iam_openid_connect_provider.eks.arn,
    "oidc_url": aws_iam_openid_connect_provider.eks.url })
  tags = var.tags
}



resource "aws_iam_role" "eks_node_autoscailing" {
  name = "eks_node_autoscailing"
  assume_role_policy = templatefile("autoscailing-role.json", { 
    "oidc_arn": aws_iam_openid_connect_provider.eks.arn,
    "oidc_url": aws_iam_openid_connect_provider.eks.url })
  tags = var.tags
}

resource "aws_iam_role_policy" "eks_node_autoscailing" {
  role = aws_iam_role.eks_node_autoscailing.id
  policy = templatefile("autoscailing-role-policy.json", {
    "aws_region": var.region,
    "aws_account_id": var.aws_account_id,
    "asg_name": aws_eks_node_group.eks_node_group.resources[0].autoscaling_groups[0].name })
}


resource "aws_iam_role" "eks_node" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

