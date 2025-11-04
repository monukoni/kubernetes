module "networking" {
  source   = "./terraform/network"
  tags     = var.tags
  vpc_cidr = var.vpc_cidr
}