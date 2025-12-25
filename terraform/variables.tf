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
    "clusterName" : "eks",
    "version" : "v1"
  }
}

variable "admin_user" {
  type    = string
  default = "ADMIN"
}

variable "name" {
  type    = string
  default = "default"
}

variable "gh_oidc_sub" {
  type = string
  default = "repo:monukoni/kubernetes:*"
}

# move to vault
variable "cloudflare_api_token" {
  type = string
}

# move to vault
variable "zone_id" {
  type = string
}

locals {
  elb_arn  = try(data.aws_resourcegroupstaggingapi_resources.consul_elb_search.resource_tag_mapping_list[0].resource_arn, "")
  elb_name = element(split("/", local.elb_arn), length(split("/", local.elb_arn)) - 1)
}