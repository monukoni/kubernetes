resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"

  create_namespace = true
  namespace = "consul"

  values = [ file(var.consul_variables_path) ]
}