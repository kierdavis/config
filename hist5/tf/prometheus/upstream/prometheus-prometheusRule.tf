# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheus-prometheusRule.yaml

resource "kubernetes_manifest" "prometheusrule_monitoring_prometheus_k8s_prometheus_rules" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "PrometheusRule"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
        "prometheus" = "k8s"
        "role" = "alert-rules"
      }
      "name" = "prometheus-k8s-prometheus-rules"
      "namespace" = "monitoring"
    }
    "spec" = {
      "groups" = [
        {
          "name" = "prometheus"
          "rules" = [
            {
              "alert" = "PrometheusBadConfig"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has failed to reload its configuration."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusbadconfig"
                "summary" = "Failed Prometheus configuration reload."
              }
              "expr" = <<-EOT
              # Without max_over_time, failed scrapes could create false negatives, see
              # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
              max_over_time(prometheus_config_last_reload_successful{job="prometheus-k8s",namespace="monitoring"}[5m]) == 0
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "PrometheusNotificationQueueRunningFull"
              "annotations" = {
                "description" = "Alert notification queue of Prometheus {{$labels.namespace}}/{{$labels.pod}} is running full."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusnotificationqueuerunningfull"
                "summary" = "Prometheus alert notification queue predicted to run full in less than 30m."
              }
              "expr" = <<-EOT
              # Without min_over_time, failed scrapes could create false negatives, see
              # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
              (
                predict_linear(prometheus_notifications_queue_length{job="prometheus-k8s",namespace="monitoring"}[5m], 60 * 30)
              >
                min_over_time(prometheus_notifications_queue_capacity{job="prometheus-k8s",namespace="monitoring"}[5m])
              )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusErrorSendingAlertsToSomeAlertmanagers"
              "annotations" = {
                "description" = "{{ printf \"%.1f\" $value }}% errors while sending alerts from Prometheus {{$labels.namespace}}/{{$labels.pod}} to Alertmanager {{$labels.alertmanager}}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheuserrorsendingalertstosomealertmanagers"
                "summary" = "Prometheus has encountered more than 1% errors sending alerts to a specific Alertmanager."
              }
              "expr" = <<-EOT
              (
                rate(prometheus_notifications_errors_total{job="prometheus-k8s",namespace="monitoring"}[5m])
              /
                rate(prometheus_notifications_sent_total{job="prometheus-k8s",namespace="monitoring"}[5m])
              )
              * 100
              > 1
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusNotConnectedToAlertmanagers"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} is not connected to any Alertmanagers."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusnotconnectedtoalertmanagers"
                "summary" = "Prometheus is not connected to any Alertmanagers."
              }
              "expr" = <<-EOT
              # Without max_over_time, failed scrapes could create false negatives, see
              # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
              max_over_time(prometheus_notifications_alertmanagers_discovered{job="prometheus-k8s",namespace="monitoring"}[5m]) < 1
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusTSDBReloadsFailing"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has detected {{$value | humanize}} reload failures over the last 3h."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheustsdbreloadsfailing"
                "summary" = "Prometheus has issues reloading blocks from disk."
              }
              "expr" = <<-EOT
              increase(prometheus_tsdb_reloads_failures_total{job="prometheus-k8s",namespace="monitoring"}[3h]) > 0
              
              EOT
              "for" = "4h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusTSDBCompactionsFailing"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has detected {{$value | humanize}} compaction failures over the last 3h."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheustsdbcompactionsfailing"
                "summary" = "Prometheus has issues compacting blocks."
              }
              "expr" = <<-EOT
              increase(prometheus_tsdb_compactions_failed_total{job="prometheus-k8s",namespace="monitoring"}[3h]) > 0
              
              EOT
              "for" = "4h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusNotIngestingSamples"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} is not ingesting samples."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusnotingestingsamples"
                "summary" = "Prometheus is not ingesting samples."
              }
              "expr" = <<-EOT
              (
                rate(prometheus_tsdb_head_samples_appended_total{job="prometheus-k8s",namespace="monitoring"}[5m]) <= 0
              and
                (
                  sum without(scrape_job) (prometheus_target_metadata_cache_entries{job="prometheus-k8s",namespace="monitoring"}) > 0
                or
                  sum without(rule_group) (prometheus_rule_group_rules{job="prometheus-k8s",namespace="monitoring"}) > 0
                )
              )
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusDuplicateTimestamps"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} is dropping {{ printf \"%.4g\" $value  }} samples/s with different values but duplicated timestamp."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusduplicatetimestamps"
                "summary" = "Prometheus is dropping samples with duplicate timestamps."
              }
              "expr" = <<-EOT
              rate(prometheus_target_scrapes_sample_duplicate_timestamp_total{job="prometheus-k8s",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusOutOfOrderTimestamps"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} is dropping {{ printf \"%.4g\" $value  }} samples/s with timestamps arriving out of order."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusoutofordertimestamps"
                "summary" = "Prometheus drops samples with out-of-order timestamps."
              }
              "expr" = <<-EOT
              rate(prometheus_target_scrapes_sample_out_of_order_total{job="prometheus-k8s",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusRemoteStorageFailures"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} failed to send {{ printf \"%.1f\" $value }}% of the samples to {{ $labels.remote_name}}:{{ $labels.url }}"
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusremotestoragefailures"
                "summary" = "Prometheus fails to send samples to remote storage."
              }
              "expr" = <<-EOT
              (
                (rate(prometheus_remote_storage_failed_samples_total{job="prometheus-k8s",namespace="monitoring"}[5m]) or rate(prometheus_remote_storage_samples_failed_total{job="prometheus-k8s",namespace="monitoring"}[5m]))
              /
                (
                  (rate(prometheus_remote_storage_failed_samples_total{job="prometheus-k8s",namespace="monitoring"}[5m]) or rate(prometheus_remote_storage_samples_failed_total{job="prometheus-k8s",namespace="monitoring"}[5m]))
                +
                  (rate(prometheus_remote_storage_succeeded_samples_total{job="prometheus-k8s",namespace="monitoring"}[5m]) or rate(prometheus_remote_storage_samples_total{job="prometheus-k8s",namespace="monitoring"}[5m]))
                )
              )
              * 100
              > 1
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "PrometheusRemoteWriteBehind"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} remote write is {{ printf \"%.1f\" $value }}s behind for {{ $labels.remote_name}}:{{ $labels.url }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusremotewritebehind"
                "summary" = "Prometheus remote write is behind."
              }
              "expr" = <<-EOT
              # Without max_over_time, failed scrapes could create false negatives, see
              # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
              (
                max_over_time(prometheus_remote_storage_highest_timestamp_in_seconds{job="prometheus-k8s",namespace="monitoring"}[5m])
              - ignoring(remote_name, url) group_right
                max_over_time(prometheus_remote_storage_queue_highest_sent_timestamp_seconds{job="prometheus-k8s",namespace="monitoring"}[5m])
              )
              > 120
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "PrometheusRemoteWriteDesiredShards"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} remote write desired shards calculation wants to run {{ $value }} shards for queue {{ $labels.remote_name}}:{{ $labels.url }}, which is more than the max of {{ printf `prometheus_remote_storage_shards_max{instance=\"%s\",job=\"prometheus-k8s\",namespace=\"monitoring\"}` $labels.instance | query | first | value }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusremotewritedesiredshards"
                "summary" = "Prometheus remote write desired shards calculation wants to run more than configured max shards."
              }
              "expr" = <<-EOT
              # Without max_over_time, failed scrapes could create false negatives, see
              # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
              (
                max_over_time(prometheus_remote_storage_shards_desired{job="prometheus-k8s",namespace="monitoring"}[5m])
              >
                max_over_time(prometheus_remote_storage_shards_max{job="prometheus-k8s",namespace="monitoring"}[5m])
              )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusRuleFailures"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has failed to evaluate {{ printf \"%.0f\" $value }} rules in the last 5m."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusrulefailures"
                "summary" = "Prometheus is failing rule evaluations."
              }
              "expr" = <<-EOT
              increase(prometheus_rule_evaluation_failures_total{job="prometheus-k8s",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "PrometheusMissingRuleEvaluations"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has missed {{ printf \"%.0f\" $value }} rule group evaluations in the last 5m."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusmissingruleevaluations"
                "summary" = "Prometheus is missing rule evaluations due to slow rule group evaluation."
              }
              "expr" = <<-EOT
              increase(prometheus_rule_group_iterations_missed_total{job="prometheus-k8s",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusTargetLimitHit"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has dropped {{ printf \"%.0f\" $value }} targets because the number of targets exceeded the configured target_limit."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheustargetlimithit"
                "summary" = "Prometheus has dropped targets because some scrape configs have exceeded the targets limit."
              }
              "expr" = <<-EOT
              increase(prometheus_target_scrape_pool_exceeded_target_limit_total{job="prometheus-k8s",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusLabelLimitHit"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has dropped {{ printf \"%.0f\" $value }} targets because some samples exceeded the configured label_limit, label_name_length_limit or label_value_length_limit."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheuslabellimithit"
                "summary" = "Prometheus has dropped targets because some scrape configs have exceeded the labels limit."
              }
              "expr" = <<-EOT
              increase(prometheus_target_scrape_pool_exceeded_label_limits_total{job="prometheus-k8s",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusScrapeBodySizeLimitHit"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has failed {{ printf \"%.0f\" $value }} scrapes in the last 5m because some targets exceeded the configured body_size_limit."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusscrapebodysizelimithit"
                "summary" = "Prometheus has dropped some targets that exceeded body size limit."
              }
              "expr" = <<-EOT
              increase(prometheus_target_scrapes_exceeded_body_size_limit_total{job="prometheus-k8s",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusScrapeSampleLimitHit"
              "annotations" = {
                "description" = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has failed {{ printf \"%.0f\" $value }} scrapes in the last 5m because some targets exceeded the configured sample_limit."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusscrapesamplelimithit"
                "summary" = "Prometheus has failed scrapes that have exceeded the configured sample limit."
              }
              "expr" = <<-EOT
              increase(prometheus_target_scrapes_exceeded_sample_limit_total{job="prometheus-k8s",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusTargetSyncFailure"
              "annotations" = {
                "description" = "{{ printf \"%.0f\" $value }} targets in Prometheus {{$labels.namespace}}/{{$labels.pod}} have failed to sync because invalid configuration was supplied."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheustargetsyncfailure"
                "summary" = "Prometheus has failed to sync targets."
              }
              "expr" = <<-EOT
              increase(prometheus_target_sync_failed_total{job="prometheus-k8s",namespace="monitoring"}[30m]) > 0
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "PrometheusErrorSendingAlertsToAnyAlertmanager"
              "annotations" = {
                "description" = "{{ printf \"%.1f\" $value }}% minimum errors while sending alerts from Prometheus {{$labels.namespace}}/{{$labels.pod}} to any Alertmanager."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheuserrorsendingalertstoanyalertmanager"
                "summary" = "Prometheus encounters more than 3% errors sending alerts to any Alertmanager."
              }
              "expr" = <<-EOT
              min without (alertmanager) (
                rate(prometheus_notifications_errors_total{job="prometheus-k8s",namespace="monitoring",alertmanager!~``}[5m])
              /
                rate(prometheus_notifications_sent_total{job="prometheus-k8s",namespace="monitoring",alertmanager!~``}[5m])
              )
              * 100
              > 3
              
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
