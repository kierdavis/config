# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/kubePrometheus-prometheusRule.yaml

resource "kubernetes_manifest" "prometheusrule_monitoring_kube_prometheus_rules" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "PrometheusRule"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "kube-prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "prometheus" = "k8s"
        "role" = "alert-rules"
      }
      "name" = "kube-prometheus-rules"
      "namespace" = "monitoring"
    }
    "spec" = {
      "groups" = [
        {
          "name" = "general.rules"
          "rules" = [
            {
              "alert" = "TargetDown"
              "annotations" = {
                "description" = "{{ printf \"%.4g\" $value }}% of the {{ $labels.job }}/{{ $labels.service }} targets in {{ $labels.namespace }} namespace are down."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/general/targetdown"
                "summary" = "One or more targets are unreachable."
              }
              "expr" = "100 * (count(up == 0) BY (job, namespace, service) / count(up) BY (job, namespace, service)) > 10"
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "Watchdog"
              "annotations" = {
                "description" = <<-EOT
                This is an alert meant to ensure that the entire alerting pipeline is functional.
                This alert is always firing, therefore it should always be firing in Alertmanager
                and always fire against a receiver. There are integrations with various notification
                mechanisms that send a notification when this alert is not firing. For example the
                "DeadMansSnitch" integration in PagerDuty.
                
                EOT
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/general/watchdog"
                "summary" = "An alert that should always be firing to certify that Alertmanager is working properly."
              }
              "expr" = "vector(1)"
              "labels" = {
                "severity" = "none"
              }
            },
            {
              "alert" = "InfoInhibitor"
              "annotations" = {
                "description" = <<-EOT
                This is an alert that is used to inhibit info alerts.
                By themselves, the info-level alerts are sometimes very noisy, but they are relevant when combined with
                other alerts.
                This alert fires whenever there's a severity="info" alert, and stops firing when another alert with a
                severity of 'warning' or 'critical' starts firing on the same namespace.
                This alert should be routed to a null receiver and configured to inhibit alerts with severity="info".
                
                EOT
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/general/infoinhibitor"
                "summary" = "Info-level alert inhibition."
              }
              "expr" = "ALERTS{severity = \"info\"} == 1 unless on(namespace) ALERTS{alertname != \"InfoInhibitor\", severity =~ \"warning|critical\", alertstate=\"firing\"} == 1"
              "labels" = {
                "severity" = "none"
              }
            },
          ]
        },
        {
          "name" = "node-network"
          "rules" = [
            {
              "alert" = "NodeNetworkInterfaceFlapping"
              "annotations" = {
                "description" = "Network interface \"{{ $labels.device }}\" changing its up status often on node-exporter {{ $labels.namespace }}/{{ $labels.pod }}"
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/general/nodenetworkinterfaceflapping"
                "summary" = "Network interface is often changing its status"
              }
              "expr" = <<-EOT
              changes(node_network_up{job="node-exporter",device!~"veth.+"}[2m]) > 2
              
              EOT
              "for" = "2m"
              "labels" = {
                "severity" = "warning"
              }
            },
          ]
        },
        {
          "name" = "kube-prometheus-node-recording.rules"
          "rules" = [
            {
              "expr" = "sum(rate(node_cpu_seconds_total{mode!=\"idle\",mode!=\"iowait\",mode!=\"steal\"}[3m])) BY (instance)"
              "record" = "instance:node_cpu:rate:sum"
            },
            {
              "expr" = "sum(rate(node_network_receive_bytes_total[3m])) BY (instance)"
              "record" = "instance:node_network_receive_bytes:rate:sum"
            },
            {
              "expr" = "sum(rate(node_network_transmit_bytes_total[3m])) BY (instance)"
              "record" = "instance:node_network_transmit_bytes:rate:sum"
            },
            {
              "expr" = "sum(rate(node_cpu_seconds_total{mode!=\"idle\",mode!=\"iowait\",mode!=\"steal\"}[5m])) WITHOUT (cpu, mode) / ON(instance) GROUP_LEFT() count(sum(node_cpu_seconds_total) BY (instance, cpu)) BY (instance)"
              "record" = "instance:node_cpu:ratio"
            },
            {
              "expr" = "sum(rate(node_cpu_seconds_total{mode!=\"idle\",mode!=\"iowait\",mode!=\"steal\"}[5m]))"
              "record" = "cluster:node_cpu:sum_rate5m"
            },
            {
              "expr" = "cluster:node_cpu:sum_rate5m / count(sum(node_cpu_seconds_total) BY (instance, cpu))"
              "record" = "cluster:node_cpu:ratio"
            },
          ]
        },
        {
          "name" = "kube-prometheus-general.rules"
          "rules" = [
            {
              "expr" = "count without(instance, pod, node) (up == 1)"
              "record" = "count:up1"
            },
            {
              "expr" = "count without(instance, pod, node) (up == 0)"
              "record" = "count:up0"
            },
          ]
        },
      ]
    }
  }
  depends_on = [module.setup]
}
