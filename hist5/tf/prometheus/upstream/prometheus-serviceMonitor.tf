# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheus-serviceMonitor.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_prometheus_k8s" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "prometheus-k8s"
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
          "app.kubernetes.io/component" = "prometheus"
          "app.kubernetes.io/instance" = "k8s"
          "app.kubernetes.io/name" = "prometheus"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
    }
  }
  depends_on = [module.setup]
}