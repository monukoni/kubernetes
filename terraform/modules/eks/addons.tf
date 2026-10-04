resource "aws_eks_addon" "vpc-cni" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.20.4-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "eks-node-monitoring-agent" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-node-monitoring-agent"
  addon_version = "v1.4.1-eksbuild.1"
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.9-eksbuild.3"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "kube-proxy"
  addon_version = "v1.33.3-eksbuild.4"
}
