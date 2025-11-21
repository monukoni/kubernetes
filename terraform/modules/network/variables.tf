locals {
  avz-cidrs = [
    for idx in range(length(data.aws_availability_zones.avz.names) * 2) :
    cidrsubnet(var.vpc_cidr, 4, idx + 1)
  ]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "name" {
  type    = string
  default = "eks"
}