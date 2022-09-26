# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheusAdapter-clusterRole.yaml

resource "kubernetes_manifest" "clusterrole_monitoring_prometheus_adapter" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
      }
      "name" = "prometheus-adapter"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
          "namespaces",
          "pods",
          "services",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
  depends_on = [module.setup]
}
