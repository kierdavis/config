# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./alertmanager-serviceMonitor.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_alertmanager_main" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "alert-router"
        "app.kubernetes.io/instance" = "main"
        "app.kubernetes.io/name" = "alertmanager"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.24.0"
      }
      "name" = "alertmanager-main"
      "namespace" = "monitoring"
    }
    "spec" = {
      "endpoints" = [
        {
          "interval" = "30s"
          "port" = "web"
        },
        {
          "interval" = "30s"
          "port" = "reloader-web"
        },
      ]
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "alert-router"
          "app.kubernetes.io/instance" = "main"
          "app.kubernetes.io/name" = "alertmanager"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
    }
  }
  depends_on = [module.setup]
}
