# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/nodeExporter-prometheusRule.yaml

resource "kubernetes_manifest" "prometheusrule_monitoring_node_exporter_rules" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "PrometheusRule"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "node-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "1.3.1"
        "prometheus" = "k8s"
        "role" = "alert-rules"
      }
      "name" = "node-exporter-rules"
      "namespace" = "monitoring"
    }
    "spec" = {
      "groups" = [
        {
          "name" = "node-exporter"
          "rules" = [
            {
              "alert" = "NodeFilesystemSpaceFillingUp"
              "annotations" = {
                "description" = "Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available space left and is filling up."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemspacefillingup"
                "summary" = "Filesystem is predicted to run out of space within the next 24 hours."
              }
              "expr" = <<-EOT
              (
                node_filesystem_avail_bytes{job="node-exporter",fstype!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!=""} * 100 < 15
              and
                predict_linear(node_filesystem_avail_bytes{job="node-exporter",fstype!=""}[6h], 24*60*60) < 0
              and
                node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
              )
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeFilesystemSpaceFillingUp"
              "annotations" = {
                "description" = "Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available space left and is filling up fast."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemspacefillingup"
                "summary" = "Filesystem is predicted to run out of space within the next 4 hours."
              }
              "expr" = <<-EOT
              (
                node_filesystem_avail_bytes{job="node-exporter",fstype!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!=""} * 100 < 10
              and
                predict_linear(node_filesystem_avail_bytes{job="node-exporter",fstype!=""}[6h], 4*60*60) < 0
              and
                node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
              )
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "NodeFilesystemAlmostOutOfSpace"
              "annotations" = {
                "description" = "Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available space left."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemalmostoutofspace"
                "summary" = "Filesystem has less than 5% space left."
              }
              "expr" = <<-EOT
              (
                node_filesystem_avail_bytes{job="node-exporter",fstype!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!=""} * 100 < 5
              and
                node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
              )
              
              EOT
              "for" = "30m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeFilesystemAlmostOutOfSpace"
              "annotations" = {
                "description" = "Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available space left."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemalmostoutofspace"
                "summary" = "Filesystem has less than 3% space left."
              }
              "expr" = <<-EOT
              (
                node_filesystem_avail_bytes{job="node-exporter",fstype!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!=""} * 100 < 3
              and
                node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
              )
              
              EOT
              "for" = "30m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "NodeFilesystemFilesFillingUp"
              "annotations" = {
                "description" = "Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available inodes left and is filling up."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemfilesfillingup"
                "summary" = "Filesystem is predicted to run out of inodes within the next 24 hours."
              }
              "expr" = <<-EOT
              (
                node_filesystem_files_free{job="node-exporter",fstype!=""} / node_filesystem_files{job="node-exporter",fstype!=""} * 100 < 40
              and
                predict_linear(node_filesystem_files_free{job="node-exporter",fstype!=""}[6h], 24*60*60) < 0
              and
                node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
              )
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeFilesystemFilesFillingUp"
              "annotations" = {
                "description" = "Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available inodes left and is filling up fast."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemfilesfillingup"
                "summary" = "Filesystem is predicted to run out of inodes within the next 4 hours."
              }
              "expr" = <<-EOT
              (
                node_filesystem_files_free{job="node-exporter",fstype!=""} / node_filesystem_files{job="node-exporter",fstype!=""} * 100 < 20
              and
                predict_linear(node_filesystem_files_free{job="node-exporter",fstype!=""}[6h], 4*60*60) < 0
              and
                node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
              )
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "NodeFilesystemAlmostOutOfFiles"
              "annotations" = {
                "description" = "Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available inodes left."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemalmostoutoffiles"
                "summary" = "Filesystem has less than 5% inodes left."
              }
              "expr" = <<-EOT
              (
                node_filesystem_files_free{job="node-exporter",fstype!=""} / node_filesystem_files{job="node-exporter",fstype!=""} * 100 < 5
              and
                node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
              )
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeFilesystemAlmostOutOfFiles"
              "annotations" = {
                "description" = "Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available inodes left."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemalmostoutoffiles"
                "summary" = "Filesystem has less than 3% inodes left."
              }
              "expr" = <<-EOT
              (
                node_filesystem_files_free{job="node-exporter",fstype!=""} / node_filesystem_files{job="node-exporter",fstype!=""} * 100 < 3
              and
                node_filesystem_readonly{job="node-exporter",fstype!=""} == 0
              )
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "NodeNetworkReceiveErrs"
              "annotations" = {
                "description" = "{{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf \"%.0f\" $value }} receive errors in the last two minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodenetworkreceiveerrs"
                "summary" = "Network interface is reporting many receive errors."
              }
              "expr" = <<-EOT
              rate(node_network_receive_errs_total[2m]) / rate(node_network_receive_packets_total[2m]) > 0.01
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeNetworkTransmitErrs"
              "annotations" = {
                "description" = "{{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf \"%.0f\" $value }} transmit errors in the last two minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodenetworktransmiterrs"
                "summary" = "Network interface is reporting many transmit errors."
              }
              "expr" = <<-EOT
              rate(node_network_transmit_errs_total[2m]) / rate(node_network_transmit_packets_total[2m]) > 0.01
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeHighNumberConntrackEntriesUsed"
              "annotations" = {
                "description" = "{{ $value | humanizePercentage }} of conntrack entries are used."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodehighnumberconntrackentriesused"
                "summary" = "Number of conntrack are getting close to the limit."
              }
              "expr" = <<-EOT
              (node_nf_conntrack_entries / node_nf_conntrack_entries_limit) > 0.75
              
              EOT
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeTextFileCollectorScrapeError"
              "annotations" = {
                "description" = "Node Exporter text file collector failed to scrape."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodetextfilecollectorscrapeerror"
                "summary" = "Node Exporter text file collector failed to scrape."
              }
              "expr" = <<-EOT
              node_textfile_scrape_error{job="node-exporter"} == 1
              
              EOT
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeClockSkewDetected"
              "annotations" = {
                "description" = "Clock on {{ $labels.instance }} is out of sync by more than 300s. Ensure NTP is configured correctly on this host."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodeclockskewdetected"
                "summary" = "Clock skew detected."
              }
              "expr" = <<-EOT
              (
                node_timex_offset_seconds > 0.05
              and
                deriv(node_timex_offset_seconds[5m]) >= 0
              )
              or
              (
                node_timex_offset_seconds < -0.05
              and
                deriv(node_timex_offset_seconds[5m]) <= 0
              )
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeClockNotSynchronising"
              "annotations" = {
                "description" = "Clock on {{ $labels.instance }} is not synchronising. Ensure NTP is configured on this host."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodeclocknotsynchronising"
                "summary" = "Clock not synchronising."
              }
              "expr" = <<-EOT
              min_over_time(node_timex_sync_status[5m]) == 0
              and
              node_timex_maxerror_seconds >= 16
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeRAIDDegraded"
              "annotations" = {
                "description" = "RAID array '{{ $labels.device }}' on {{ $labels.instance }} is in degraded state due to one or more disks failures. Number of spare drives is insufficient to fix issue automatically."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/noderaiddegraded"
                "summary" = "RAID Array is degraded"
              }
              "expr" = <<-EOT
              node_md_disks_required - ignoring (state) (node_md_disks{state="active"}) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "NodeRAIDDiskFailure"
              "annotations" = {
                "description" = "At least one device in RAID array on {{ $labels.instance }} failed. Array '{{ $labels.device }}' needs attention and possibly a disk swap."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/noderaiddiskfailure"
                "summary" = "Failed device in RAID array"
              }
              "expr" = <<-EOT
              node_md_disks{state="failed"} > 0
              
              EOT
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeFileDescriptorLimit"
              "annotations" = {
                "description" = "File descriptors limit at {{ $labels.instance }} is currently at {{ printf \"%.2f\" $value }}%."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefiledescriptorlimit"
                "summary" = "Kernel is predicted to exhaust file descriptors limit soon."
              }
              "expr" = <<-EOT
              (
                node_filefd_allocated{job="node-exporter"} * 100 / node_filefd_maximum{job="node-exporter"} > 70
              )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "NodeFileDescriptorLimit"
              "annotations" = {
                "description" = "File descriptors limit at {{ $labels.instance }} is currently at {{ printf \"%.2f\" $value }}%."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefiledescriptorlimit"
                "summary" = "Kernel is predicted to exhaust file descriptors limit soon."
              }
              "expr" = <<-EOT
              (
                node_filefd_allocated{job="node-exporter"} * 100 / node_filefd_maximum{job="node-exporter"} > 90
              )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
          ]
        },
        {
          "name" = "node-exporter.rules"
          "rules" = [
            {
              "expr" = <<-EOT
              count without (cpu, mode) (
                node_cpu_seconds_total{job="node-exporter",mode="idle"}
              )
              
              EOT
              "record" = "instance:node_num_cpu:sum"
            },
            {
              "expr" = <<-EOT
              1 - avg without (cpu) (
                sum without (mode) (rate(node_cpu_seconds_total{job="node-exporter", mode=~"idle|iowait|steal"}[5m]))
              )
              
              EOT
              "record" = "instance:node_cpu_utilisation:rate5m"
            },
            {
              "expr" = <<-EOT
              (
                node_load1{job="node-exporter"}
              /
                instance:node_num_cpu:sum{job="node-exporter"}
              )
              
              EOT
              "record" = "instance:node_load1_per_cpu:ratio"
            },
            {
              "expr" = <<-EOT
              1 - (
                (
                  node_memory_MemAvailable_bytes{job="node-exporter"}
                  or
                  (
                    node_memory_Buffers_bytes{job="node-exporter"}
                    +
                    node_memory_Cached_bytes{job="node-exporter"}
                    +
                    node_memory_MemFree_bytes{job="node-exporter"}
                    +
                    node_memory_Slab_bytes{job="node-exporter"}
                  )
                )
              /
                node_memory_MemTotal_bytes{job="node-exporter"}
              )
              
              EOT
              "record" = "instance:node_memory_utilisation:ratio"
            },
            {
              "expr" = <<-EOT
              rate(node_vmstat_pgmajfault{job="node-exporter"}[5m])
              
              EOT
              "record" = "instance:node_vmstat_pgmajfault:rate5m"
            },
            {
              "expr" = <<-EOT
              rate(node_disk_io_time_seconds_total{job="node-exporter", device=~"mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+"}[5m])
              
              EOT
              "record" = "instance_device:node_disk_io_time_seconds:rate5m"
            },
            {
              "expr" = <<-EOT
              rate(node_disk_io_time_weighted_seconds_total{job="node-exporter", device=~"mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+"}[5m])
              
              EOT
              "record" = "instance_device:node_disk_io_time_weighted_seconds:rate5m"
            },
            {
              "expr" = <<-EOT
              sum without (device) (
                rate(node_network_receive_bytes_total{job="node-exporter", device!="lo"}[5m])
              )
              
              EOT
              "record" = "instance:node_network_receive_bytes_excluding_lo:rate5m"
            },
            {
              "expr" = <<-EOT
              sum without (device) (
                rate(node_network_transmit_bytes_total{job="node-exporter", device!="lo"}[5m])
              )
              
              EOT
              "record" = "instance:node_network_transmit_bytes_excluding_lo:rate5m"
            },
            {
              "expr" = <<-EOT
              sum without (device) (
                rate(node_network_receive_drop_total{job="node-exporter", device!="lo"}[5m])
              )
              
              EOT
              "record" = "instance:node_network_receive_drop_excluding_lo:rate5m"
            },
            {
              "expr" = <<-EOT
              sum without (device) (
                rate(node_network_transmit_drop_total{job="node-exporter", device!="lo"}[5m])
              )
              
              EOT
              "record" = "instance:node_network_transmit_drop_excluding_lo:rate5m"
            },
          ]
        },
      ]
    }
  }
  depends_on = [module.setup]
}
