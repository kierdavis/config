# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./grafana-dashboardDatasources.yaml

resource "kubernetes_manifest" "secret_monitoring_grafana_datasources" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "grafana"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "8.5.5"
      }
      "name" = "grafana-datasources"
      "namespace" = "monitoring"
    }
    "stringData" = {
      "datasources.yaml" = <<-EOT
      {
          "apiVersion": 1,
          "datasources": [
              {
                  "access": "proxy",
                  "editable": false,
                  "name": "prometheus",
                  "orgId": 1,
                  "type": "prometheus",
                  "url": "http://prometheus-k8s.monitoring.svc:9090",
                  "version": 1
              }
          ]
      }
      EOT
    }
    "type" = "Opaque"
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "stringData"]
  depends_on = [module.setup]
}
