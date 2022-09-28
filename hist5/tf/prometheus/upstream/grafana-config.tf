# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/grafana-config.yaml

resource "kubernetes_manifest" "secret_monitoring_grafana_config" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "grafana"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "8.5.5"
      }
      "name" = "grafana-config"
      "namespace" = "monitoring"
    }
    "stringData" = {
      "grafana.ini" = <<-EOT
      [date_formats]
      default_timezone = UTC
      
      EOT
    }
    "type" = "Opaque"
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "stringData"]
  depends_on = [module.setup]
}
