# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/setup/namespace.yaml

resource "kubernetes_manifest" "namespace_monitoring" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "monitoring"
    }
  }
}
