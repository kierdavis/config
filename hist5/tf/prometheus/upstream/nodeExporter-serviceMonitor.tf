# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./nodeExporter-serviceMonitor.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_node_exporter" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
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
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "interval" = "15s"
          "port" = "https"
          "relabelings" = [
            {
              "action" = "replace"
              "regex" = "(.*)"
              "replacement" = "$1"
              "sourceLabels" = [
                "__meta_kubernetes_pod_node_name",
              ]
              "targetLabel" = "instance"
            },
          ]
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
      ]
      "jobLabel" = "app.kubernetes.io/name"
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "exporter"
          "app.kubernetes.io/name" = "node-exporter"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
    }
  }
  depends_on = [module.setup]
}
