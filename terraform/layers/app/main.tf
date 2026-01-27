resource "helm_release" "load-balancer" {
  name  = "load-balancer"
  chart = "../../../helm/load-balancer"

  wait            = true
  cleanup_on_fail = true
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