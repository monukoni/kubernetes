variable "tags" {
    type = map(string)
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