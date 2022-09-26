# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./grafana-dashboardSources.yaml

resource "kubernetes_manifest" "configmap_monitoring_grafana_dashboards" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "dashboards.yaml" = <<-EOT
      {
          "apiVersion": 1,
          "providers": [
              {
                  "folder": "Default",
                  "folderUid": "",
                  "name": "0",
                  "options": {
                      "path": "/grafana-dashboard-definitions/0"
                  },
                  "orgId": 1,
                  "type": "file"
              }
          ]
      }
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "grafana"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "8.5.5"
      }
      "name" = "grafana-dashboards"
      "namespace" = "monitoring"
    }
  }
  depends_on = [module.setup]
}
