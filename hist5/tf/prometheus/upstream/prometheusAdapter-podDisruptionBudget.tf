# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusAdapter-podDisruptionBudget.yaml

resource "kubernetes_manifest" "poddisruptionbudget_monitoring_prometheus_adapter" {
  manifest = {
    "apiVersion" = "policy/v1"
    "kind" = "PodDisruptionBudget"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
      }
      "name" = "prometheus-adapter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "minAvailable" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "metrics-adapter"
          "app.kubernetes.io/name" = "prometheus-adapter"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
    }
  }
  depends_on = [module.setup]
}
