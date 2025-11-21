output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "openid_connect_url" {
  value = aws_iam_openid_connect_provider.eks.url
}

output "openid_connect_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "aws_eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.eks.certificate_authority.0.data
}