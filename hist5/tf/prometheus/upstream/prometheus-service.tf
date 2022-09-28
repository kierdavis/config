# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheus-service.yaml

resource "kubernetes_manifest" "service_monitoring_prometheus_k8s" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "prometheus-k8s"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "web"
          "port" = 9090
          "targetPort" = "web"
        },
        {
          "name" = "reloader-web"
          "port" = 8080
          "targetPort" = "reloader-web"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
      "sessionAffinity" = "ClientIP"
    }
  }
  depends_on = [module.setup]
}
