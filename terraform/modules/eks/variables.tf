variable "tags" {
  type    = map(string)
  default = {}
}

variable "admin_user_arn" {
  type = string
}

variable "eks_role_arn" {
  type = string
}

variable "subnets" {

}

variable "oidc_role_path" {

}

# variable "external_secrets_access_policy_path" {
#   type = string
# }

# variable "external_secrets_pod_identity_role_path" {
#   type = string
# }

# variable "cloudflare_api_key_secret_arn" {
#   type = string
# }

variable "name" {
  type    = string
  default = "eks"
}
