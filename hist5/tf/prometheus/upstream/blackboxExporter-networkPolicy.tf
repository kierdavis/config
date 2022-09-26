# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./blackboxExporter-networkPolicy.yaml

resource "kubernetes_manifest" "networkpolicy_monitoring_blackbox_exporter" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "NetworkPolicy"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "blackbox-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.21.0"
      }
      "name" = "blackbox-exporter"
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
              "port" = 9115
              "protocol" = "TCP"
            },
            {
              "port" = 19115
              "protocol" = "TCP"
            },
          ]
        },
      ]
      "podSelector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "exporter"
          "app.kubernetes.io/name" = "blackbox-exporter"
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
