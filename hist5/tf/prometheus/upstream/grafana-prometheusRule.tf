# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./grafana-prometheusRule.yaml

resource "kubernetes_manifest" "prometheusrule_monitoring_grafana_rules" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "PrometheusRule"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "grafana"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "8.5.5"
        "prometheus" = "k8s"
        "role" = "alert-rules"
      }
      "name" = "grafana-rules"
      "namespace" = "monitoring"
    }
    "spec" = {
      "groups" = [
        {
          "name" = "GrafanaAlerts"
          "rules" = [
            {
              "alert" = "GrafanaRequestsFailing"
              "annotations" = {
                "message" = "{{ $labels.namespace }}/{{ $labels.job }}/{{ $labels.handler }} is experiencing {{ $value | humanize }}% errors"
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/grafana/grafanarequestsfailing"
              }
              "expr" = <<-EOT
              100 * namespace_job_handler_statuscode:grafana_http_request_duration_seconds_count:rate5m{handler!~"/api/datasources/proxy/:id.*|/api/ds/query|/api/tsdb/query", status_code=~"5.."}
              / ignoring (status_code)
              sum without (status_code) (namespace_job_handler_statuscode:grafana_http_request_duration_seconds_count:rate5m{handler!~"/api/datasources/proxy/:id.*|/api/ds/query|/api/tsdb/query"})
              > 50
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "warning"
              }
            },
          ]
        },
        {
          "name" = "grafana_rules"
          "rules" = [
            {
              "expr" = <<-EOT
              sum by (namespace, job, handler, status_code) (rate(grafana_http_request_duration_seconds_count[5m]))
              
              EOT
              "record" = "namespace_job_handler_statuscode:grafana_http_request_duration_seconds_count:rate5m"
            },
          ]
        },
      ]
    }
  }
  depends_on = [module.setup]
}
