# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/kubeStateMetrics-clusterRoleBinding.yaml

resource "kubernetes_manifest" "clusterrolebinding_kube_state_metrics" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.5.0"
      }
      "name" = "kube-state-metrics"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "kube-state-metrics"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "kube-state-metrics"
        "namespace" = "monitoring"
      },
    ]
  }
  depends_on = [module.setup]
}
