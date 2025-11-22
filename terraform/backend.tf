terraform {
  backend "s3" {
    bucket = "terraform-project-state-bucket312"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
