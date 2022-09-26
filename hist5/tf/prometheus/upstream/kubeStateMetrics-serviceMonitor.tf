# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./kubeStateMetrics-serviceMonitor.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_kube_state_metrics" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.5.0"
      }
      "name" = "kube-state-metrics"
      "namespace" = "monitoring"
    }
    "spec" = {
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "honorLabels" = true
          "interval" = "30s"
          "port" = "https-main"
          "relabelings" = [
            {
              "action" = "labeldrop"
              "regex" = "(pod|service|endpoint|namespace)"
            },
          ]
          "scheme" = "https"
          "scrapeTimeout" = "30s"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "interval" = "30s"
          "port" = "https-self"
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
          "app.kubernetes.io/name" = "kube-state-metrics"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
    }
  }
  depends_on = [module.setup]
}
