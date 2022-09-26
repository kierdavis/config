# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./blackboxExporter-serviceAccount.yaml

resource "kubernetes_manifest" "serviceaccount_monitoring_blackbox_exporter" {
  manifest = {
    "apiVersion" = "v1"
    "automountServiceAccountToken" = false
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "blackbox-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.21.0"
      }
      "name" = "blackbox-exporter"
      "namespace" = "monitoring"
    }
  }
  depends_on = [module.setup]
}
