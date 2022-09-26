# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheusAdapter-serviceMonitor.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_prometheus_adapter" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
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
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "interval" = "30s"
          "metricRelabelings" = [
            {
              "action" = "drop"
              "regex" = "(apiserver_client_certificate_.*|apiserver_envelope_.*|apiserver_flowcontrol_.*|apiserver_storage_.*|apiserver_webhooks_.*|workqueue_.*)"
              "sourceLabels" = [
                "__name__",
              ]
            },
          ]
          "port" = "https"
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
      ]
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "metrics-adapter"
          "app.kubernetes.io/name" = "prometheus-adapter"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
    }
  }
  depends_on = [module.setup]
}
