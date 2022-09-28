# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/alertmanager-podDisruptionBudget.yaml

resource "kubernetes_manifest" "poddisruptionbudget_monitoring_alertmanager_main" {
  manifest = {
    "apiVersion" = "policy/v1"
    "kind" = "PodDisruptionBudget"
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
      "maxUnavailable" = 1
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
