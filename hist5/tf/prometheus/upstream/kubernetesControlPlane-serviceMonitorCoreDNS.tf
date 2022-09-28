# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/kubernetesControlPlane-serviceMonitorCoreDNS.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_coredns" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/name" = "coredns"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
      "name" = "coredns"
      "namespace" = "monitoring"
    }
    "spec" = {
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "interval" = "15s"
          "metricRelabelings" = [
            {
              "action" = "drop"
              "regex" = "coredns_cache_misses_total"
              "sourceLabels" = [
                "__name__",
              ]
            },
          ]
          "port" = "metrics"
        },
      ]
      "jobLabel" = "app.kubernetes.io/name"
      "namespaceSelector" = {
        "matchNames" = [
          "kube-system",
        ]
      }
      "selector" = {
        "matchLabels" = {
          "k8s-app" = "kube-dns"
        }
      }
    }
  }
  depends_on = [module.setup]
}
