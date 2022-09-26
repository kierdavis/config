# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheus-clusterRole.yaml

resource "kubernetes_manifest" "clusterrole_prometheus_k8s" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "prometheus-k8s"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes/metrics",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "nonResourceURLs" = [
          "/metrics",
        ]
        "verbs" = [
          "get",
        ]
      },
    ]
  }
  depends_on = [module.setup]
}
