# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/grafana-serviceMonitor.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_grafana" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "grafana"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "8.5.5"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "spec" = {
      "endpoints" = [
        {
          "interval" = "15s"
          "port" = "http"
        },
      ]
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/name" = "grafana"
        }
      }
    }
  }
  depends_on = [module.setup]
}
