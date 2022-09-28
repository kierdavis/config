# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/kubernetesControlPlane-serviceMonitorKubeScheduler.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_kube_scheduler" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/name" = "kube-scheduler"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
      "name" = "kube-scheduler"
      "namespace" = "monitoring"
    }
    "spec" = {
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "interval" = "30s"
          "port" = "https-metrics"
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
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
          "app.kubernetes.io/name" = "kube-scheduler"
        }
      }
    }
  }
  depends_on = [module.setup]
}
