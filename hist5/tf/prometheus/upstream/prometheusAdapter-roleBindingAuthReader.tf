# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusAdapter-roleBindingAuthReader.yaml

resource "kubernetes_manifest" "rolebinding_kube_system_resource_metrics_auth_reader" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
      }
      "name" = "resource-metrics-auth-reader"
      "namespace" = "kube-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "extension-apiserver-authentication-reader"
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
