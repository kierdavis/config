# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusAdapter-apiService.yaml

resource "kubernetes_manifest" "apiservice_v1beta1_metrics_k8s_io" {
  manifest = {
    "apiVersion" = "apiregistration.k8s.io/v1"
    "kind" = "APIService"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
      }
      "name" = "v1beta1.metrics.k8s.io"
    }
    "spec" = {
      "group" = "metrics.k8s.io"
      "groupPriorityMinimum" = 100
      "insecureSkipTLSVerify" = true
      "service" = {
        "name" = "prometheus-adapter"
        "namespace" = "monitoring"
      }
      "version" = "v1beta1"
      "versionPriority" = 100
    }
  }
  depends_on = [module.setup]
}
