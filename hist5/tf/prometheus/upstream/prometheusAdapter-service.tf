# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheusAdapter-service.yaml

resource "kubernetes_manifest" "service_monitoring_prometheus_adapter" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
      }
      "name" = "prometheus-adapter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "https"
          "port" = 443
          "targetPort" = 6443
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
    }
  }
  depends_on = [module.setup]
}
