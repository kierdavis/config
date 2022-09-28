# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/kubeStateMetrics-serviceAccount.yaml

resource "kubernetes_manifest" "serviceaccount_monitoring_kube_state_metrics" {
  manifest = {
    "apiVersion" = "v1"
    "automountServiceAccountToken" = false
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.5.0"
      }
      "name" = "kube-state-metrics"
      "namespace" = "monitoring"
    }
  }
  depends_on = [module.setup]
}
