# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusAdapter-clusterRoleBinding.yaml

resource "kubernetes_manifest" "clusterrolebinding_prometheus_adapter" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
      }
      "name" = "prometheus-adapter"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "prometheus-adapter"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-adapter"
        "namespace" = "monitoring"
      },
    ]
  }
  depends_on = [module.setup]
}
