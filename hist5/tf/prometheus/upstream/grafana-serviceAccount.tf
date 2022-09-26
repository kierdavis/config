# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./grafana-serviceAccount.yaml

resource "kubernetes_manifest" "serviceaccount_monitoring_grafana" {
  manifest = {
    "apiVersion" = "v1"
    "automountServiceAccountToken" = false
    "kind" = "ServiceAccount"
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
  }
  depends_on = [module.setup]
}
