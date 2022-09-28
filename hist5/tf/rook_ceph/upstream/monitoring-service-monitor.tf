# From https://github.com/rook/rook/blob/v1.10.1/deploy/examples/monitoring/service-monitor.yaml

resource "kubernetes_manifest" "servicemonitor_rook_ceph_rook_ceph_mgr" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "team" = "rook"
      }
      "name" = "rook-ceph-mgr"
      "namespace" = "rook-ceph"
    }
    "spec" = {
      "endpoints" = [
        {
          "interval" = "5s"
          "path" = "/metrics"
          "port" = "http-metrics"
        },
      ]
      "namespaceSelector" = {
        "matchNames" = [
          "rook-ceph",
        ]
      }
      "selector" = {
        "matchLabels" = {
          "app" = "rook-ceph-mgr"
          "ceph_daemon_id" = "a"
          "rook_cluster" = "rook-ceph"
        }
      }
    }
  }
}
