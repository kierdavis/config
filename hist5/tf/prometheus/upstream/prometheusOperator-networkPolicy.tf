# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheusOperator-networkPolicy.yaml

resource "kubernetes_manifest" "networkpolicy_monitoring_prometheus_operator" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "NetworkPolicy"
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
          ]
        },
      ]
      "podSelector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "controller"
          "app.kubernetes.io/name" = "prometheus-operator"
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
