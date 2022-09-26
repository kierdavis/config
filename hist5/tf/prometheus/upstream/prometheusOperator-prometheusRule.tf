# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheusOperator-prometheusRule.yaml

resource "kubernetes_manifest" "prometheusrule_monitoring_prometheus_operator_rules" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "PrometheusRule"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/name" = "prometheus-operator"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.57.0"
        "prometheus" = "k8s"
        "role" = "alert-rules"
      }
      "name" = "prometheus-operator-rules"
      "namespace" = "monitoring"
    }
    "spec" = {
      "groups" = [
        {
          "name" = "prometheus-operator"
          "rules" = [
            {
              "alert" = "PrometheusOperatorListErrors"
              "annotations" = {
                "description" = "Errors while performing List operations in controller {{$labels.controller}} in {{$labels.namespace}} namespace."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorlisterrors"
                "summary" = "Errors while performing list operations in controller."
              }
              "expr" = <<-EOT
              (sum by (controller,namespace) (rate(prometheus_operator_list_operations_failed_total{job="prometheus-operator",namespace="monitoring"}[10m])) / sum by (controller,namespace) (rate(prometheus_operator_list_operations_total{job="prometheus-operator",namespace="monitoring"}[10m]))) > 0.4
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusOperatorWatchErrors"
              "annotations" = {
                "description" = "Errors while performing watch operations in controller {{$labels.controller}} in {{$labels.namespace}} namespace."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorwatcherrors"
                "summary" = "Errors while performing watch operations in controller."
              }
              "expr" = <<-EOT
              (sum by (controller,namespace) (rate(prometheus_operator_watch_operations_failed_total{job="prometheus-operator",namespace="monitoring"}[5m])) / sum by (controller,namespace) (rate(prometheus_operator_watch_operations_total{job="prometheus-operator",namespace="monitoring"}[5m]))) > 0.4
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusOperatorSyncFailed"
              "annotations" = {
                "description" = "Controller {{ $labels.controller }} in {{ $labels.namespace }} namespace fails to reconcile {{ $value }} objects."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorsyncfailed"
                "summary" = "Last controller reconciliation failed"
              }
              "expr" = <<-EOT
              min_over_time(prometheus_operator_syncs{status="failed",job="prometheus-operator",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusOperatorReconcileErrors"
              "annotations" = {
                "description" = "{{ $value | humanizePercentage }} of reconciling operations failed for {{ $labels.controller }} controller in {{ $labels.namespace }} namespace."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorreconcileerrors"
                "summary" = "Errors while reconciling controller."
              }
              "expr" = <<-EOT
              (sum by (controller,namespace) (rate(prometheus_operator_reconcile_errors_total{job="prometheus-operator",namespace="monitoring"}[5m]))) / (sum by (controller,namespace) (rate(prometheus_operator_reconcile_operations_total{job="prometheus-operator",namespace="monitoring"}[5m]))) > 0.1
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusOperatorNodeLookupErrors"
              "annotations" = {
                "description" = "Errors while reconciling Prometheus in {{ $labels.namespace }} Namespace."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatornodelookuperrors"
                "summary" = "Errors while reconciling Prometheus."
              }
              "expr" = <<-EOT
              rate(prometheus_operator_node_address_lookup_errors_total{job="prometheus-operator",namespace="monitoring"}[5m]) > 0.1
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusOperatorNotReady"
              "annotations" = {
                "description" = "Prometheus operator in {{ $labels.namespace }} namespace isn't ready to reconcile {{ $labels.controller }} resources."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatornotready"
                "summary" = "Prometheus operator not ready"
              }
              "expr" = <<-EOT
              min by (controller,namespace) (max_over_time(prometheus_operator_ready{job="prometheus-operator",namespace="monitoring"}[5m]) == 0)
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "PrometheusOperatorRejectedResources"
              "annotations" = {
                "description" = "Prometheus operator in {{ $labels.namespace }} namespace rejected {{ printf \"%0.0f\" $value }} {{ $labels.controller }}/{{ $labels.resource }} resources."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/prometheusoperatorrejectedresources"
                "summary" = "Resources rejected by Prometheus operator"
              }
              "expr" = <<-EOT
              min_over_time(prometheus_operator_managed_resources{state="rejected",job="prometheus-operator",namespace="monitoring"}[5m]) > 0
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "warning"
              }
            },
          ]
        },
        {
          "name" = "config-reloaders"
          "rules" = [
            {
              "alert" = "ConfigReloaderSidecarErrors"
              "annotations" = {
                "description" = <<-EOT
                Errors encountered while the {{$labels.pod}} config-reloader sidecar attempts to sync config in {{$labels.namespace}} namespace.
                As a result, configuration for service running in {{$labels.pod}} may be stale and cannot be updated anymore.
                EOT
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/configreloadersidecarerrors"
                "summary" = "config-reloader sidecar has not had a successful reload for 10m"
              }
              "expr" = <<-EOT
              max_over_time(reloader_last_reload_successful{namespace=~".+"}[5m]) == 0
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
          ]
        },
      ]
    }
  }
  depends_on = [module.setup]
}