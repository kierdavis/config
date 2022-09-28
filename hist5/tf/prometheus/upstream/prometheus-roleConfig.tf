# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheus-roleConfig.yaml

resource "kubernetes_manifest" "role_monitoring_prometheus_k8s_config" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "prometheus-k8s-config"
      "namespace" = "monitoring"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "get",
        ]
      },
    ]
  }
  depends_on = [module.setup]
}
