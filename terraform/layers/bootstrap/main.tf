module "gh_oidc" {
  source   = "../../modules/gh_oidc"
  oidc_gha_role_policy_path = "../../policies/oidc_gha_role_policy.json"
  oidc_gha_role_path = "../../policies/oidc_gha_role.json"
  gh_oidc_sub = var.gh_oidc_sub
}

resource "aws_ecr_repository" "frontend" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "load_testing" {
  name                 = "load_testing"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}