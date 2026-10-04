terraform {
  backend "s3" {
    bucket       = "terraform-project-state-bucket31"
    key          = "terraform-app.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}
