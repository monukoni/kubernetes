variable "region" {
  default = "eu-central-1"
}

variable "aws_account_id" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "tags" {
  type = map(string)
  default = {
    "clusterName" : "eks",
    "version" : "v1"
  }
}

variable "admin_user" {
  type    = string
  default = "ADMIN"
}

variable "bucket_name" {
  default = "${state_bucket_name}"
}