# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusOperator-clusterRoleBinding.yaml

resource "kubernetes_manifest" "clusterrolebinding_prometheus_operator" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/name" = "prometheus-operator"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.57.0"
      }
      "name" = "prometheus-operator"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "prometheus-operator"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-operator"
        "namespace" = "monitoring"
      },
    ]
  }
  depends_on = [module.setup]
}
