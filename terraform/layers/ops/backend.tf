terraform {
  backend "s3" {
    bucket       = "terraform-project-state-bucket31"
    key          = "terraform-ops.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}
