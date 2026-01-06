output "eks_private_subnets" {
  value = aws_subnet.eks_private_subnets
}

output "eks_public_subnets" {
  value = aws_subnet.eks_public_subnets
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}