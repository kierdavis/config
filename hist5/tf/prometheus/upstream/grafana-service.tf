# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./grafana-service.yaml

resource "kubernetes_manifest" "service_monitoring_grafana" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "grafana"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "8.5.5"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http"
          "port" = 3000
          "targetPort" = "http"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "grafana"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
    }
  }
  depends_on = [module.setup]
}
