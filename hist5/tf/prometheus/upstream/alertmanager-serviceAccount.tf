# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/alertmanager-serviceAccount.yaml

resource "kubernetes_manifest" "serviceaccount_monitoring_alertmanager_main" {
  manifest = {
    "apiVersion" = "v1"
    "automountServiceAccountToken" = false
    "kind" = "ServiceAccount"
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
  }
  depends_on = [module.setup]
}
