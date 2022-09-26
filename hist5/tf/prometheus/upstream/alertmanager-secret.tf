# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./alertmanager-secret.yaml

resource "kubernetes_manifest" "secret_monitoring_alertmanager_main" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
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
    "stringData" = {
      "alertmanager.yaml" = <<-EOT
      "global":
        "resolve_timeout": "5m"
      "inhibit_rules":
      - "equal":
        - "namespace"
        - "alertname"
        "source_matchers":
        - "severity = critical"
        "target_matchers":
        - "severity =~ warning|info"
      - "equal":
        - "namespace"
        - "alertname"
        "source_matchers":
        - "severity = warning"
        "target_matchers":
        - "severity = info"
      - "equal":
        - "namespace"
        "source_matchers":
        - "alertname = InfoInhibitor"
        "target_matchers":
        - "severity = info"
      "receivers":
      - "name": "Default"
      - "name": "Watchdog"
      - "name": "Critical"
      - "name": "null"
      "route":
        "group_by":
        - "namespace"
        "group_interval": "5m"
        "group_wait": "30s"
        "receiver": "Default"
        "repeat_interval": "12h"
        "routes":
        - "matchers":
          - "alertname = Watchdog"
          "receiver": "Watchdog"
        - "matchers":
          - "alertname = InfoInhibitor"
          "receiver": "null"
        - "matchers":
          - "severity = critical"
          "receiver": "Critical"
      EOT
    }
    "type" = "Opaque"
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "stringData"]
  depends_on = [module.setup]
}
