# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheus-prometheus.yaml

resource "kubernetes_manifest" "prometheus_monitoring_k8s" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "Prometheus"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "k8s"
      "namespace" = "monitoring"
    }
    "spec" = {
      "alerting" = {
        "alertmanagers" = [
          {
            "apiVersion" = "v2"
            "name" = "alertmanager-main"
            "namespace" = "monitoring"
            "port" = "web"
          },
        ]
      }
      "enableFeatures" = []
      "externalLabels" = {}
      "image" = "quay.io/prometheus/prometheus:v2.36.1"
      "nodeSelector" = {
        "kubernetes.io/os" = "linux"
      }
      "podMetadata" = {
        "labels" = {
          "app.kubernetes.io/component" = "prometheus"
          "app.kubernetes.io/instance" = "k8s"
          "app.kubernetes.io/name" = "prometheus"
          "app.kubernetes.io/part-of" = "kube-prometheus"
          "app.kubernetes.io/version" = "2.36.1"
        }
      }
      "podMonitorNamespaceSelector" = {}
      "podMonitorSelector" = {}
      "probeNamespaceSelector" = {}
      "probeSelector" = {}
      "replicas" = 2
      "resources" = {
        "requests" = {
          "memory" = "400Mi"
        }
      }
      "ruleNamespaceSelector" = {}
      "ruleSelector" = {}
      "securityContext" = {
        "fsGroup" = 2000
        "runAsNonRoot" = true
        "runAsUser" = 1000
      }
      "serviceAccountName" = "prometheus-k8s"
      "serviceMonitorNamespaceSelector" = {}
      "serviceMonitorSelector" = {}
      "version" = "2.36.1"
    }
  }
  depends_on = [module.setup]
}
