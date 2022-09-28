# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusAdapter-clusterRoleServerResources.yaml

resource "kubernetes_manifest" "clusterrole_resource_metrics_server_resources" {
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
      "name" = "resource-metrics-server-resources"
    }
    "rules" = [
      {
        "apiGroups" = [
          "metrics.k8s.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
    ]
  }
  depends_on = [module.setup]
}
