# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheusAdapter-clusterRoleAggregatedMetricsReader.yaml

resource "kubernetes_manifest" "clusterrole_monitoring_system_aggregated_metrics_reader" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
        "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
        "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
        "rbac.authorization.k8s.io/aggregate-to-view" = "true"
      }
      "name" = "system:aggregated-metrics-reader"
    }
    "rules" = [
      {
        "apiGroups" = [
          "metrics.k8s.io",
        ]
        "resources" = [
          "pods",
          "nodes",
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
