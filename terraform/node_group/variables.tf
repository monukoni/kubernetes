variable "tags" {
    type = map(string)
    default = {}
}

variable "region" {
  type =  string
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