# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusOperator-serviceMonitor.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_prometheus_operator" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
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
    "spec" = {
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "honorLabels" = true
          "port" = "https"
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
      ]
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "controller"
          "app.kubernetes.io/name" = "prometheus-operator"
          "app.kubernetes.io/part-of" = "kube-prometheus"
          "app.kubernetes.io/version" = "0.57.0"
        }
      }
    }
  }
  depends_on = [module.setup]
}
