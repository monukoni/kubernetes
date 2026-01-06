variable "gh_oidc_sub" {
  type = string
}
variable "oidc_gha_role_policy_path" {
  type = string
  default = "./policies/oidc_gha_role_policy.json"
}

variable "oidc_gha_role_path" {
  type = string
  default = "./policies/oidc_gha_role.json"
}
