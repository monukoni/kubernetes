variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "version" {
  type    = string
  default = "1.0.0"
}

variable "ami_name" {
  type    = string
  default = "github-runner-ubuntu"
}

variable "vpc_id" {
  type    = string
  default = ""
}
