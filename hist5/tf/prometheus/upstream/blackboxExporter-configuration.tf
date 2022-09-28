# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/blackboxExporter-configuration.yaml

resource "kubernetes_manifest" "configmap_monitoring_blackbox_exporter_configuration" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "config.yml" = <<-EOT
      "modules":
        "http_2xx":
          "http":
            "preferred_ip_protocol": "ip4"
          "prober": "http"
        "http_post_2xx":
          "http":
            "method": "POST"
            "preferred_ip_protocol": "ip4"
          "prober": "http"
        "irc_banner":
          "prober": "tcp"
          "tcp":
            "preferred_ip_protocol": "ip4"
            "query_response":
            - "send": "NICK prober"
            - "send": "USER prober prober prober :prober"
            - "expect": "PING :([^ ]+)"
              "send": "PONG $${1}"
            - "expect": "^:[^ ]+ 001"
        "pop3s_banner":
          "prober": "tcp"
          "tcp":
            "preferred_ip_protocol": "ip4"
            "query_response":
            - "expect": "^+OK"
            "tls": true
            "tls_config":
              "insecure_skip_verify": false
        "ssh_banner":
          "prober": "tcp"
          "tcp":
            "preferred_ip_protocol": "ip4"
            "query_response":
            - "expect": "^SSH-2.0-"
        "tcp_connect":
          "prober": "tcp"
          "tcp":
            "preferred_ip_protocol": "ip4"
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "blackbox-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.21.0"
      }
      "name" = "blackbox-exporter-configuration"
      "namespace" = "monitoring"
    }
  }
  depends_on = [module.setup]
}
