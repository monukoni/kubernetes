data "aws_route_table" "rt" {
  vpc_id = aws_vpc.eks_vpc.id
}
