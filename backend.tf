terraform {
  backend "s3" {
    bucket = "${state_bucket_name}"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
