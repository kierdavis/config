# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheusAdapter-networkPolicy.yaml

resource "kubernetes_manifest" "networkpolicy_monitoring_prometheus_adapter" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "NetworkPolicy"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
      }
      "name" = "prometheus-adapter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "egress" = [
        {},
      ]
      "ingress" = [
        {},
      ]
      "podSelector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "metrics-adapter"
          "app.kubernetes.io/name" = "prometheus-adapter"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
      "policyTypes" = [
        "Egress",
        "Ingress",
      ]
    }
  }
  depends_on = [module.setup]
}
