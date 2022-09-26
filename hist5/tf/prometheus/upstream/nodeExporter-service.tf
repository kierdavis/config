# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./nodeExporter-service.yaml

resource "kubernetes_manifest" "service_monitoring_node_exporter" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "node-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "1.3.1"
      }
      "name" = "node-exporter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "clusterIP" = "None"
      "ports" = [
        {
          "name" = "https"
          "port" = 9100
          "targetPort" = "https"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "node-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
    }
  }
  depends_on = [module.setup]
}
