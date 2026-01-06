terraform {
  backend "s3" {
    bucket = "terraform-project-state-bucket312"
    key    = "terraform-ops.tfstate"
    region = "eu-central-1"
  }
}
