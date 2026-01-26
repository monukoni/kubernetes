variable "gh_oidc_sub" {
  type    = string
  default = "repo:monukoni/kubernetes:*"
}

variable "region" {
  default = "eu-central-1"
}

variable "name" {

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
