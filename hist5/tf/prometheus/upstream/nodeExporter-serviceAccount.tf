# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/nodeExporter-serviceAccount.yaml

resource "kubernetes_manifest" "serviceaccount_monitoring_node_exporter" {
  manifest = {
    "apiVersion" = "v1"
    "automountServiceAccountToken" = false
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "node-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "1.3.1"
      }
      "name" = "node-exporter"
      "namespace" = "monitoring"
    }
  }
  depends_on = [module.setup]
}
