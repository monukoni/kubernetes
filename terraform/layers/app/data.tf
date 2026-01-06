data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster" "eks" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}


data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-project-state-bucket312"
    key    = "terraform-ops.tfstate"
    region = var.region
  }
  workspace = var.name
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