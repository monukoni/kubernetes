output "eks_private_subnets" {
  value = module.networking.eks_private_subnets
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "eks_public_subnets" {
  value = module.networking.eks_public_subnets
}
