# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./kubernetesControlPlane-serviceMonitorKubelet.yaml

resource "kubernetes_manifest" "servicemonitor_monitoring_kubelet" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/name" = "kubelet"
        "app.kubernetes.io/part-of" = "kube-prometheus"
      }
      "name" = "kubelet"
      "namespace" = "monitoring"
    }
    "spec" = {
      "endpoints" = [
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "honorLabels" = true
          "interval" = "30s"
          "metricRelabelings" = [
            {
              "action" = "drop"
              "regex" = "kubelet_(pod_worker_latency_microseconds|pod_start_latency_microseconds|cgroup_manager_latency_microseconds|pod_worker_start_latency_microseconds|pleg_relist_latency_microseconds|pleg_relist_interval_microseconds|runtime_operations|runtime_operations_latency_microseconds|runtime_operations_errors|eviction_stats_age_microseconds|device_plugin_registration_count|device_plugin_alloc_latency_microseconds|network_plugin_operations_latency_microseconds)"
              "sourceLabels" = [
                "__name__",
              ]
            },
            {
              "action" = "drop"
              "regex" = "scheduler_(e2e_scheduling_latency_microseconds|scheduling_algorithm_predicate_evaluation|scheduling_algorithm_priority_evaluation|scheduling_algorithm_preemption_evaluation|scheduling_algorithm_latency_microseconds|binding_latency_microseconds|scheduling_latency_seconds)"
              "sourceLabels" = [
                "__name__",
              ]
            },
            {
              "action" = "drop"
              "regex" = "apiserver_(request_count|request_latencies|request_latencies_summary|dropped_requests|storage_data_key_generation_latencies_microseconds|storage_transformation_failures_total|storage_transformation_latencies_microseconds|proxy_tunnel_sync_latency_secs|longrunning_gauge|registered_watchers)"
              "sourceLabels" = [
                "__name__",
              ]
            },
            {
              "action" = "drop"
              "regex" = "kubelet_docker_(operations|operations_latency_microseconds|operations_errors|operations_timeout)"
              "sourceLabels" = [
                "__name__",
              ]
            },
            {
              "action" = "drop"
              "regex" = "reflector_(items_per_list|items_per_watch|list_duration_seconds|lists_total|short_watches_total|watch_duration_seconds|watches_total)"
              "sourceLabels" = [
                "__name__",
              ]
            },
            {
              "action" = "drop"
              "regex" = "etcd_(helper_cache_hit_count|helper_cache_miss_count|helper_cache_entry_count|object_counts|request_cache_get_latencies_summary|request_cache_add_latencies_summary|request_latencies_summary)"
              "sourceLabels" = [
                "__name__",
              ]
            },
            {
              "action" = "drop"
              "regex" = "transformation_(transformation_latencies_microseconds|failures_total)"
              "sourceLabels" = [
                "__name__",
              ]
            },
            {
              "action" = "drop"
              "regex" = "(admission_quota_controller_adds|admission_quota_controller_depth|admission_quota_controller_longest_running_processor_microseconds|admission_quota_controller_queue_latency|admission_quota_controller_unfinished_work_seconds|admission_quota_controller_work_duration|APIServiceOpenAPIAggregationControllerQueue1_adds|APIServiceOpenAPIAggregationControllerQueue1_depth|APIServiceOpenAPIAggregationControllerQueue1_longest_running_processor_microseconds|APIServiceOpenAPIAggregationControllerQueue1_queue_latency|APIServiceOpenAPIAggregationControllerQueue1_retries|APIServiceOpenAPIAggregationControllerQueue1_unfinished_work_seconds|APIServiceOpenAPIAggregationControllerQueue1_work_duration|APIServiceRegistrationController_adds|APIServiceRegistrationController_depth|APIServiceRegistrationController_longest_running_processor_microseconds|APIServiceRegistrationController_queue_latency|APIServiceRegistrationController_retries|APIServiceRegistrationController_unfinished_work_seconds|APIServiceRegistrationController_work_duration|autoregister_adds|autoregister_depth|autoregister_longest_running_processor_microseconds|autoregister_queue_latency|autoregister_retries|autoregister_unfinished_work_seconds|autoregister_work_duration|AvailableConditionController_adds|AvailableConditionController_depth|AvailableConditionController_longest_running_processor_microseconds|AvailableConditionController_queue_latency|AvailableConditionController_retries|AvailableConditionController_unfinished_work_seconds|AvailableConditionController_work_duration|crd_autoregistration_controller_adds|crd_autoregistration_controller_depth|crd_autoregistration_controller_longest_running_processor_microseconds|crd_autoregistration_controller_queue_latency|crd_autoregistration_controller_retries|crd_autoregistration_controller_unfinished_work_seconds|crd_autoregistration_controller_work_duration|crdEstablishing_adds|crdEstablishing_depth|crdEstablishing_longest_running_processor_microseconds|crdEstablishing_queue_latency|crdEstablishing_retries|crdEstablishing_unfinished_work_seconds|crdEstablishing_work_duration|crd_finalizer_adds|crd_finalizer_depth|crd_finalizer_longest_running_processor_microseconds|crd_finalizer_queue_latency|crd_finalizer_retries|crd_finalizer_unfinished_work_seconds|crd_finalizer_work_duration|crd_naming_condition_controller_adds|crd_naming_condition_controller_depth|crd_naming_condition_controller_longest_running_processor_microseconds|crd_naming_condition_controller_queue_latency|crd_naming_condition_controller_retries|crd_naming_condition_controller_unfinished_work_seconds|crd_naming_condition_controller_work_duration|crd_openapi_controller_adds|crd_openapi_controller_depth|crd_openapi_controller_longest_running_processor_microseconds|crd_openapi_controller_queue_latency|crd_openapi_controller_retries|crd_openapi_controller_unfinished_work_seconds|crd_openapi_controller_work_duration|DiscoveryController_adds|DiscoveryController_depth|DiscoveryController_longest_running_processor_microseconds|DiscoveryController_queue_latency|DiscoveryController_retries|DiscoveryController_unfinished_work_seconds|DiscoveryController_work_duration|kubeproxy_sync_proxy_rules_latency_microseconds|non_structural_schema_condition_controller_adds|non_structural_schema_condition_controller_depth|non_structural_schema_condition_controller_longest_running_processor_microseconds|non_structural_schema_condition_controller_queue_latency|non_structural_schema_condition_controller_retries|non_structural_schema_condition_controller_unfinished_work_seconds|non_structural_schema_condition_controller_work_duration|rest_client_request_latency_seconds|storage_operation_errors_total|storage_operation_status_count)"
              "sourceLabels" = [
                "__name__",
              ]
            },
          ]
          "port" = "https-metrics"
          "relabelings" = [
            {
              "sourceLabels" = [
                "__metrics_path__",
              ]
              "targetLabel" = "metrics_path"
            },
          ]
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "honorLabels" = true
          "honorTimestamps" = false
          "interval" = "30s"
          "metricRelabelings" = [
            {
              "action" = "drop"
              "regex" = "container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)"
              "sourceLabels" = [
                "__name__",
              ]
            },
            {
              "action" = "drop"
              "regex" = "(container_spec_.*|container_file_descriptors|container_sockets|container_threads_max|container_threads|container_start_time_seconds|container_last_seen);;"
              "sourceLabels" = [
                "__name__",
                "pod",
                "namespace",
              ]
            },
            {
              "action" = "drop"
              "regex" = "(container_blkio_device_usage_total);.+"
              "sourceLabels" = [
                "__name__",
                "container",
              ]
            },
          ]
          "path" = "/metrics/cadvisor"
          "port" = "https-metrics"
          "relabelings" = [
            {
              "sourceLabels" = [
                "__metrics_path__",
              ]
              "targetLabel" = "metrics_path"
            },
          ]
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
        {
          "bearerTokenFile" = "/var/run/secrets/kubernetes.io/serviceaccount/token"
          "honorLabels" = true
          "interval" = "30s"
          "path" = "/metrics/probes"
          "port" = "https-metrics"
          "relabelings" = [
            {
              "sourceLabels" = [
                "__metrics_path__",
              ]
              "targetLabel" = "metrics_path"
            },
          ]
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
      ]
      "jobLabel" = "app.kubernetes.io/name"
      "namespaceSelector" = {
        "matchNames" = [
          "kube-system",
        ]
      }
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/name" = "kubelet"
        }
      }
    }
  }
  depends_on = [module.setup]
}
