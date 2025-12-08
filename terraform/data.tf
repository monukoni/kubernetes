data "aws_iam_user" "root" {
  user_name = var.admin_user
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}


data "aws_resourcegroupstaggingapi_resources" "consul_elb_search" {
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = "kubernetes.io/service-name"
    values = ["consul/consul-ingress-gateway"]
  }

  depends_on = [helm_release.load-balancer]
}


data "aws_elb" "consul_ingress" {
  name = local.elb_name
}