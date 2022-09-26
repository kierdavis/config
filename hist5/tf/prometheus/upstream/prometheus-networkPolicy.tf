# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheus-networkPolicy.yaml

resource "kubernetes_manifest" "networkpolicy_monitoring_prometheus_k8s" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "NetworkPolicy"
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
              "port" = 9090
              "protocol" = "TCP"
            },
            {
              "port" = 8080
              "protocol" = "TCP"
            },
          ]
        },
        {
          "from" = [
            {
              "podSelector" = {
                "matchLabels" = {
                  "app.kubernetes.io/name" = "grafana"
                }
              }
            },
          ]
          "ports" = [
            {
              "port" = 9090
              "protocol" = "TCP"
            },
          ]
        },
      ]
      "podSelector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "prometheus"
          "app.kubernetes.io/instance" = "k8s"
          "app.kubernetes.io/name" = "prometheus"
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
