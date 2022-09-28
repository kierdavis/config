# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/kubeStateMetrics-service.yaml

resource "kubernetes_manifest" "service_monitoring_kube_state_metrics" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
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
      "clusterIP" = "None"
      "ports" = [
        {
          "name" = "https-main"
          "port" = 8443
          "targetPort" = "https-main"
        },
        {
          "name" = "https-self"
          "port" = 9443
          "targetPort" = "https-self"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
    }
  }
  depends_on = [module.setup]
}
