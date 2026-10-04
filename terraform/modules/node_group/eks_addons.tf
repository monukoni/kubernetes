resource "aws_eks_addon" "ebs-csi-driver" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.52.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
  depends_on               = [aws_eks_node_group.eks_node_group]
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = var.cluster_name
  addon_name    = "coredns"
  addon_version = "v1.14.3-eksbuild.3"
  depends_on    = [aws_eks_node_group.eks_node_group]
}

resource "aws_eks_addon" "metrics-server" {
  cluster_name  = var.cluster_name
  addon_name    = "metrics-server"
  addon_version = "v0.8.0-eksbuild.6"
  timeouts {
    create = "10m"
  }
  depends_on = [aws_eks_node_group.eks_node_group]
}
