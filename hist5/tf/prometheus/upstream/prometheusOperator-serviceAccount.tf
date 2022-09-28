# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusOperator-serviceAccount.yaml

resource "kubernetes_manifest" "serviceaccount_monitoring_prometheus_operator" {
  manifest = {
    "apiVersion" = "v1"
    "automountServiceAccountToken" = false
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/name" = "prometheus-operator"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.57.0"
      }
      "name" = "prometheus-operator"
      "namespace" = "monitoring"
    }
  }
  depends_on = [module.setup]
}
