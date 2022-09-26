# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./alertmanager-alertmanager.yaml

resource "kubernetes_manifest" "alertmanager_monitoring_main" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "Alertmanager"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "alert-router"
        "app.kubernetes.io/instance" = "main"
        "app.kubernetes.io/name" = "alertmanager"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.24.0"
      }
      "name" = "main"
      "namespace" = "monitoring"
    }
    "spec" = {
      "image" = "quay.io/prometheus/alertmanager:v0.24.0"
      "nodeSelector" = {
        "kubernetes.io/os" = "linux"
      }
      "podMetadata" = {
        "labels" = {
          "app.kubernetes.io/component" = "alert-router"
          "app.kubernetes.io/instance" = "main"
          "app.kubernetes.io/name" = "alertmanager"
          "app.kubernetes.io/part-of" = "kube-prometheus"
          "app.kubernetes.io/version" = "0.24.0"
        }
      }
      "replicas" = 3
      "resources" = {
        "limits" = {
          "cpu" = "100m"
          "memory" = "100Mi"
        }
        "requests" = {
          "cpu" = "4m"
          "memory" = "100Mi"
        }
      }
      "securityContext" = {
        "fsGroup" = 2000
        "runAsNonRoot" = true
        "runAsUser" = 1000
      }
      "serviceAccountName" = "alertmanager-main"
      "version" = "0.24.0"
    }
  }
  depends_on = [module.setup]
}