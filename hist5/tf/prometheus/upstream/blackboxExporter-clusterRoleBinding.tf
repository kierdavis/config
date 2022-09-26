# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./blackboxExporter-clusterRoleBinding.yaml

resource "kubernetes_manifest" "clusterrolebinding_monitoring_blackbox_exporter" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "blackbox-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.21.0"
      }
      "name" = "blackbox-exporter"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "blackbox-exporter"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "blackbox-exporter"
        "namespace" = "monitoring"
      },
    ]
  }
  depends_on = [module.setup]
}
