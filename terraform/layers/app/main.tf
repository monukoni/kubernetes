resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  create_namespace = true
  namespace        = "argocd"

  version = "9.3.7"

  wait            = true
  cleanup_on_fail = true
}

resource "kubernetes_manifest" "app_of_apps" {
  manifest = file("../../../argocd/app-of-apps.yaml")
  depends_on = [helm_release.argocd]
}

# resource "cloudflare_dns_record" "main_dns_record" {
#   zone_id = var.zone_id
#   name    = "@"
#   ttl     = 300
#   type    = "CNAME"
#   comment = "record to aws lb"
#   content = data.aws_elb.consul_ingress.dns_name
#   proxied = false
# }
