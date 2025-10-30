variable "region" {
    default = "eu-central-1"
}

locals {
  avz-cidrs = formatlist("10.0.%v.0/24", range(1, length(data.aws_availability_zones.avz.names) + 1))
  vpc-cidr = "10.0.0.0/16"
}

variable "tags" {
  type = map(string)
  default = {
    "clusterName": "eks",
    "version": "v1"
  }
}

variable "admin_user" {
  type = string
  default = "ADMIN"
}