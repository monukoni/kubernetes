resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  create_namespace = true
  namespace        = "monitoring"

  wait            = true
  cleanup_on_fail = true

  values = [file(var.grafana_values_path)]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  create_namespace = true
  namespace        = "monitoring"

  wait            = true
  cleanup_on_fail = true

  values = [file(var.prometheus_values_path)]
}

resource "helm_release" "grafana-prometheus-intentions" {
  chart = "../../../helm/service-intentions"
  name  = "grafana-prometheus-intentions"

  wait            = true
  cleanup_on_fail = true
}