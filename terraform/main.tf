module "networking" {
  source   = "./modules/network"
  name     = var.name
  tags     = var.tags
  vpc_cidr = var.vpc_cidr
  region   = var.region
}

module "iam" {
  source         = "./modules/iam"
  name           = var.name
  tags           = var.tags
  aws_account_id = data.aws_caller_identity.current.account_id
  region         = var.region
}

module "eks" {
  source         = "./modules/eks"
  name           = var.name
  admin_user_arn = data.aws_iam_user.root.arn
  eks_role_arn   = module.iam.eks_role_arn
  subnets        = module.networking.eks_private_subnets[*].id
  oidc_role_path = "./policies/oidc-role.json"
}

module "node_group" {
  source                        = "./modules/node_group"
  name                          = var.name
  region                        = var.region
  instance_types                = ["c7i-flex.large"]
  cluster_name                  = module.eks.cluster_name
  eks_subnets                   = module.networking.eks_private_subnets
  openid_connect_arn            = module.eks.openid_connect_arn
  openid_connect_url            = module.eks.openid_connect_url
  eks_node_role_arn             = module.iam.eks_node_role
  aws_account_id                = data.aws_caller_identity.current.account_id
  autoscailing_role_path        = "./policies/autoscailing-role.json"
  autoscailing_role_policy_path = "./policies/autoscailing-role-policy.json"
  ebs_csi_driver_role_path      = "./policies/ebs_csi_driver_role.json"
}

resource "kubernetes_storage_class" "gp2_default" {
  metadata {
    name = "default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  allow_volume_expansion = "true"
  volume_binding_mode    = "WaitForFirstConsumer"
  reclaim_policy         = "Delete"
  parameters = {
    type   = "gp2"
    fsType = "ext4"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  depends_on          = [module.eks]
}

module "consul" {
  source                = "./modules/consul"
  consul_variables_path = "../helm-values/consul-values.yml"
  name                  = var.name
  depends_on            = [module.node_group, module.networking, module.iam, module.eks]
}

module "monitoring" {
  source                 = "./modules/monitoring"
  grafana_values_path    = "../helm-values/grafana-values.yml"
  prometheus_values_path = "../helm-values/prometheus-values.yml"
  depends_on             = [module.node_group, module.eks, module.consul]
}

resource "helm_release" "backend" {
  name  = "backend"
  chart = "../helm/backend"

  wait            = true
  cleanup_on_fail = true

  values = [file("../helm-values/backend-values.yml")]

  depends_on = [module.eks, module.consul, module.node_group]
}

resource "helm_release" "frontend" {
  name  = "frontend"
  chart = "../helm/frontend"

  wait            = true
  cleanup_on_fail = true

  depends_on = [module.eks, module.consul, module.node_group]
}

resource "helm_release" "load-balancer" {
  name  = "load-balancer"
  chart = "../helm/load-balancer"

  wait            = true
  cleanup_on_fail = true

  depends_on = [module.eks, module.consul, module.node_group, helm_release.frontend]
}

resource "cloudflare_dns_record" "main_dns_record" {
  zone_id = var.zone_id
  name    = "@"
  ttl     = 300
  type    = "CNAME"
  comment = "record to aws lb"
  content = data.aws_elb.consul_ingress.dns_name
  proxied = false
}

resource "aws_ecr_repository" "frontend" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  count = terraform.workspace == "default" ? 1 : 0
}

resource "aws_ecr_repository" "backend" {
  name                 = "backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  count = terraform.workspace == "default" ? 1 : 0
}

resource "aws_ecr_repository" "load_testing" {
  name                 = "load_testing"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  count = terraform.workspace == "default" ? 1 : 0
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]
  count = terraform.workspace == "default" ? 1 : 0
}

resource "aws_iam_role" "github_actions_OIDC" {
  name = "github_actions_oidc-${var.name}"
  assume_role_policy = templatefile("./policies/oidc_githubactions_role.json", {
    "oidc_arn" : aws_iam_openid_connect_provider.github_actions[0].arn,
    "gh_oidc_sub" : var.gh_oidc_sub
  })
}

resource "aws_iam_policy" "github_actions_OIDC_policy" {
  name   = "github_actions_oidc_policy-${var.name}"
  policy = file("./policies/oidc_gha_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "github_actions_OIDC_policy_attach" {
  role       = aws_iam_role.github_actions_OIDC.name
  policy_arn = aws_iam_policy.github_actions_OIDC_policy.arn
}

resource "aws_eks_access_entry" "github_action" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions_OIDC.arn
}

resource "aws_eks_access_policy_association" "gha_tf_plan_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.github_action.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}