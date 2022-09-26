# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./alertmanager-networkPolicy.yaml

resource "kubernetes_manifest" "networkpolicy_monitoring_alertmanager_main" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "NetworkPolicy"
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
              "port" = 9093
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
                  "app.kubernetes.io/name" = "alertmanager"
                }
              }
            },
          ]
          "ports" = [
            {
              "port" = 9094
              "protocol" = "TCP"
            },
            {
              "port" = 9094
              "protocol" = "UDP"
            },
          ]
        },
      ]
      "podSelector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "alert-router"
          "app.kubernetes.io/instance" = "main"
          "app.kubernetes.io/name" = "alertmanager"
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
