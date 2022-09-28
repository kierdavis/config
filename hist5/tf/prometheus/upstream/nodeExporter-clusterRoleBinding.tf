# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/nodeExporter-clusterRoleBinding.yaml

resource "kubernetes_manifest" "clusterrolebinding_node_exporter" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "node-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "1.3.1"
      }
      "name" = "node-exporter"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "node-exporter"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "node-exporter"
        "namespace" = "monitoring"
      },
    ]
  }
  depends_on = [module.setup]
}
