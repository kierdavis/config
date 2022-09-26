# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./blackboxExporter-clusterRole.yaml

resource "kubernetes_manifest" "clusterrole_blackbox_exporter" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "blackbox-exporter"
    }
    "rules" = [
      {
        "apiGroups" = [
          "authentication.k8s.io",
        ]
        "resources" = [
          "tokenreviews",
        ]
        "verbs" = [
          "create",
        ]
      },
      {
        "apiGroups" = [
          "authorization.k8s.io",
        ]
        "resources" = [
          "subjectaccessreviews",
        ]
        "verbs" = [
          "create",
        ]
      },
    ]
  }
  depends_on = [module.setup]
}
