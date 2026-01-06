module "consul" {
  source                = "../../modules/consul"
  consul_variables_path = "../../../helm-values/consul-values.yml"
  name                  = var.name
}

module "monitoring" {
  source                 = "../../modules/monitoring"
  grafana_values_path    = "../../../helm-values/grafana-values.yml"
  prometheus_values_path = "../../../helm-values/prometheus-values.yml"
  depends_on             = [module.consul]
}

resource "helm_release" "backend" {
  name  = "backend"
  chart = "../../../helm/backend"

  wait            = true
  cleanup_on_fail = true

  values = [file("../../../helm-values/backend-values.yml")]

  depends_on = [module.consul]
}

resource "helm_release" "frontend" {
  name  = "frontend"
  chart = "../../../helm/frontend"

  wait            = true
  cleanup_on_fail = true

  depends_on = [module.consul]
}

resource "helm_release" "load-balancer" {
  name  = "load-balancer"
  chart = "../../../helm/load-balancer"

  wait            = true
  cleanup_on_fail = true

  depends_on = [module.consul, helm_release.frontend]
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