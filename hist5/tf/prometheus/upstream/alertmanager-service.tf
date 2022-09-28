# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/alertmanager-service.yaml

resource "kubernetes_manifest" "service_monitoring_alertmanager_main" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "alert-router"
        "app.kubernetes.io/instance" = "main"
        "app.kubernetes.io/name" = "alertmanager"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.24.0"
      }
      "name" = "alertmanager-main"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "web"
          "port" = 9093
          "targetPort" = "web"
        },
        {
          "name" = "reloader-web"
          "port" = 8080
          "targetPort" = "reloader-web"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "alert-router"
        "app.kubernetes.io/instance" = "main"
        "app.kubernetes.io/name" = "alertmanager"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
      "sessionAffinity" = "ClientIP"
    }
  }
  depends_on = [module.setup]
}
