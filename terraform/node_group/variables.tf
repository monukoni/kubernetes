variable "tags" {
  type    = map(string)
  default = {}
}

variable "region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "openid_connect_arn" {
  type = string
}

variable "openid_connect_url" {
  type = string
}

variable "eks_node_role_arn" {

}

variable "cluster_name" {

}

variable "eks_subnets" {

}

variable "autoscailing_role_policy_path" {
  type = string
}

variable "autoscailing_role_path" {
  type = string
}

variable "name" {
  type    = string
  default = "eks"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "ebs_csi_driver_role_path" {}