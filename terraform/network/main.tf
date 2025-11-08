resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

data "aws_availability_zones" "avz" {
}

resource "aws_subnet" "eks_subnets" {
  vpc_id            = aws_vpc.eks_vpc.id
  availability_zone = data.aws_availability_zones.avz.names[count.index]
  cidr_block        = local.avz-cidrs[count.index]
  map_public_ip_on_launch = true

  count = length(data.aws_availability_zones.avz.names)

  tags = var.tags
}

resource "aws_route" "r" {
  route_table_id         = data.aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = var.tags
}