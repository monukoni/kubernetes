locals {
  avz_cidrs = [
    for idx in range(var.az_count * 2) :
    cidrsubnet(var.vpc_cidr, 6, idx + 1)
  ]
}

variable "az_count" {
  default = 3
  type = number
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "name" {
  type    = string
  default = "eks"
}