# variable "name" {
#   type    = string
#   default = "default"
# }

# # move to vault
# variable "cloudflare_api_token" {
#   type = string
# }

# # move to vault
# variable "zone_id" {
#   type = string
# }

variable "region" {
  default = "eu-central-1"
}

# locals {
#   elb_arn  = try(data.aws_resourcegroupstaggingapi_resources.consul_elb_search.resource_tag_mapping_list[0].resource_arn, "")
#   elb_name = element(split("/", local.elb_arn), length(split("/", local.elb_arn)) - 1)
# }