# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./kubeStateMetrics-networkPolicy.yaml

resource "kubernetes_manifest" "networkpolicy_monitoring_kube_state_metrics" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "NetworkPolicy"
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
      "egress" = [
        {},
      ]
      "ingress" = [
        {
          "from" = [
            {
              "podSelector" = {
                "matchLabels" = {
                  "app.kubernetes.io/name" = "prometheus"
                }
              }
            },
          ]
          "ports" = [
            {
              "port" = 8443
              "protocol" = "TCP"
            },
            {
              "port" = 9443
              "protocol" = "TCP"
            },
          ]
        },
      ]
      "podSelector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "exporter"
          "app.kubernetes.io/name" = "kube-state-metrics"
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
