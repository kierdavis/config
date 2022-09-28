# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/kubeStateMetrics-prometheusRule.yaml

resource "kubernetes_manifest" "prometheusrule_monitoring_kube_state_metrics_rules" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "PrometheusRule"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.5.0"
        "prometheus" = "k8s"
        "role" = "alert-rules"
      }
      "name" = "kube-state-metrics-rules"
      "namespace" = "monitoring"
    }
    "spec" = {
      "groups" = [
        {
          "name" = "kube-state-metrics"
          "rules" = [
            {
              "alert" = "KubeStateMetricsListErrors"
              "annotations" = {
                "description" = "kube-state-metrics is experiencing errors at an elevated rate in list operations. This is likely causing it to not be able to expose metrics about Kubernetes objects correctly or at all."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kube-state-metrics/kubestatemetricslisterrors"
                "summary" = "kube-state-metrics is experiencing errors in list operations."
              }
              "expr" = <<-EOT
              (sum(rate(kube_state_metrics_list_total{job="kube-state-metrics",result="error"}[5m]))
                /
              sum(rate(kube_state_metrics_list_total{job="kube-state-metrics"}[5m])))
              > 0.01
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubeStateMetricsWatchErrors"
              "annotations" = {
                "description" = "kube-state-metrics is experiencing errors at an elevated rate in watch operations. This is likely causing it to not be able to expose metrics about Kubernetes objects correctly or at all."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kube-state-metrics/kubestatemetricswatcherrors"
                "summary" = "kube-state-metrics is experiencing errors in watch operations."
              }
              "expr" = <<-EOT
              (sum(rate(kube_state_metrics_watch_total{job="kube-state-metrics",result="error"}[5m]))
                /
              sum(rate(kube_state_metrics_watch_total{job="kube-state-metrics"}[5m])))
              > 0.01
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubeStateMetricsShardingMismatch"
              "annotations" = {
                "description" = "kube-state-metrics pods are running with different --total-shards configuration, some Kubernetes objects may be exposed multiple times or not exposed at all."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kube-state-metrics/kubestatemetricsshardingmismatch"
                "summary" = "kube-state-metrics sharding is misconfigured."
              }
              "expr" = <<-EOT
              stdvar (kube_state_metrics_total_shards{job="kube-state-metrics"}) != 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubeStateMetricsShardsMissing"
              "annotations" = {
                "description" = "kube-state-metrics shards are missing, some Kubernetes objects are not being exposed."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kube-state-metrics/kubestatemetricsshardsmissing"
                "summary" = "kube-state-metrics shards are missing."
              }
              "expr" = <<-EOT
              2^max(kube_state_metrics_total_shards{job="kube-state-metrics"}) - 1
                -
              sum( 2 ^ max by (shard_ordinal) (kube_state_metrics_shard_ordinal{job="kube-state-metrics"}) )
              != 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
          ]
        },
      ]
    }
  }
  depends_on = [module.setup]
}
