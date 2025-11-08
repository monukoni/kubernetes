variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_account_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}