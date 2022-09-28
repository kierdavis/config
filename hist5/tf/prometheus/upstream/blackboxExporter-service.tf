# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/blackboxExporter-service.yaml

resource "kubernetes_manifest" "service_monitoring_blackbox_exporter" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "blackbox-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.21.0"
      }
      "name" = "blackbox-exporter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "https"
          "port" = 9115
          "targetPort" = "https"
        },
        {
          "name" = "probe"
          "port" = 19115
          "targetPort" = "http"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "blackbox-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
    }
  }
  depends_on = [module.setup]
}
