variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "tags" {
  type = map(string)
  default = {
    "clusterName" : var.name,
    "version" : "v1"
  }
}

variable "admin_user" {
  type    = string
  default = "ADMIN"
}

variable "name" {
  type    = string
  default = "eks"
}