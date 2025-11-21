resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({
    "Name" : "${var.name}_vpc" },
    var.tags
  )
}

resource "aws_subnet" "eks_private_subnets" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = local.avz-cidrs[count.index]
  availability_zone = data.aws_availability_zones.avz.names[count.index]

  count = length(data.aws_availability_zones.avz.names)

  tags = merge({
    "Name" : "${var.name}_private${count.index}_subnet" },
    var.tags
  )
}

resource "aws_subnet" "eks_public_subnets" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = local.avz-cidrs[count.index + length(data.aws_availability_zones.avz.names)]
  availability_zone = data.aws_availability_zones.avz.names[count.index]

  count = length(data.aws_availability_zones.avz.names)

  tags = merge({
    "Name" : "${var.name}_public${count.index}_subnet" },
    var.tags
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = merge({
    "Name" : "${var.name}_igw" },
    var.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge({
    "Name" : "${var.name}_rt_public" },
    var.tags
  )
}

resource "aws_route_table_association" "eks_public_subnets" {
  subnet_id      = aws_subnet.eks_public_subnets[count.index].id
  route_table_id = aws_route_table.public.id

  count = length(aws_subnet.eks_public_subnets)
}

resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.gw]

  tags = merge({
    "Name" : "${var.name}_eip_nat" },
    var.tags
  )
}

resource "aws_nat_gateway" "eks" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.eks_public_subnets[0].id
  depends_on    = [aws_internet_gateway.gw]
  tags = merge({
    "Name" : "${var.name}_nat" },
    var.tags
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks.id
  }
  count = length(aws_subnet.eks_private_subnets)

  tags = merge({
    "Name" : "${var.name}_rt${count.index}_private" },
    var.tags
  )
}


resource "aws_route_table_association" "eks_private_subnets" {
  subnet_id      = aws_subnet.eks_private_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id

  count = length(aws_subnet.eks_private_subnets)
}
