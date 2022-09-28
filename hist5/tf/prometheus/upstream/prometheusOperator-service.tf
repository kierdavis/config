# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusOperator-service.yaml

resource "kubernetes_manifest" "service_monitoring_prometheus_operator" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
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
      "clusterIP" = "None"
      "ports" = [
        {
          "name" = "https"
          "port" = 8443
          "targetPort" = "https"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/name" = "prometheus-operator"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
    }
  }
  depends_on = [module.setup]
}
