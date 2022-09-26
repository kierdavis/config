# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./kubernetesControlPlane-prometheusRule.yaml

resource "kubernetes_manifest" "prometheusrule_monitoring_kubernetes_monitoring_rules" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "PrometheusRule"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/name" = "kube-prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "prometheus" = "k8s"
        "role" = "alert-rules"
      }
      "name" = "kubernetes-monitoring-rules"
      "namespace" = "monitoring"
    }
    "spec" = {
      "groups" = [
        {
          "name" = "kubernetes-apps"
          "rules" = [
            {
              "alert" = "KubePodCrashLooping"
              "annotations" = {
                "description" = "Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) is in waiting state (reason: \"CrashLoopBackOff\")."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepodcrashlooping"
                "summary" = "Pod is crash looping."
              }
              "expr" = <<-EOT
              max_over_time(kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics"}[5m]) >= 1
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubePodNotReady"
              "annotations" = {
                "description" = "Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in a non-ready state for longer than 15 minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepodnotready"
                "summary" = "Pod has been in a non-ready state for more than 15 minutes."
              }
              "expr" = <<-EOT
              sum by (namespace, pod, cluster) (
                max by(namespace, pod, cluster) (
                  kube_pod_status_phase{job="kube-state-metrics", phase=~"Pending|Unknown"}
                ) * on(namespace, pod, cluster) group_left(owner_kind) topk by(namespace, pod, cluster) (
                  1, max by(namespace, pod, owner_kind, cluster) (kube_pod_owner{owner_kind!="Job"})
                )
              ) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeDeploymentGenerationMismatch"
              "annotations" = {
                "description" = "Deployment generation for {{ $labels.namespace }}/{{ $labels.deployment }} does not match, this indicates that the Deployment has failed but has not been rolled back."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedeploymentgenerationmismatch"
                "summary" = "Deployment generation mismatch due to possible roll-back"
              }
              "expr" = <<-EOT
              kube_deployment_status_observed_generation{job="kube-state-metrics"}
                !=
              kube_deployment_metadata_generation{job="kube-state-metrics"}
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeDeploymentReplicasMismatch"
              "annotations" = {
                "description" = "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has not matched the expected number of replicas for longer than 15 minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedeploymentreplicasmismatch"
                "summary" = "Deployment has not matched the expected number of replicas."
              }
              "expr" = <<-EOT
              (
                kube_deployment_spec_replicas{job="kube-state-metrics"}
                  >
                kube_deployment_status_replicas_available{job="kube-state-metrics"}
              ) and (
                changes(kube_deployment_status_replicas_updated{job="kube-state-metrics"}[10m])
                  ==
                0
              )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeStatefulSetReplicasMismatch"
              "annotations" = {
                "description" = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} has not matched the expected number of replicas for longer than 15 minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubestatefulsetreplicasmismatch"
                "summary" = "Deployment has not matched the expected number of replicas."
              }
              "expr" = <<-EOT
              (
                kube_statefulset_status_replicas_ready{job="kube-state-metrics"}
                  !=
                kube_statefulset_status_replicas{job="kube-state-metrics"}
              ) and (
                changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics"}[10m])
                  ==
                0
              )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeStatefulSetGenerationMismatch"
              "annotations" = {
                "description" = "StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset }} does not match, this indicates that the StatefulSet has failed but has not been rolled back."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubestatefulsetgenerationmismatch"
                "summary" = "StatefulSet generation mismatch due to possible roll-back"
              }
              "expr" = <<-EOT
              kube_statefulset_status_observed_generation{job="kube-state-metrics"}
                !=
              kube_statefulset_metadata_generation{job="kube-state-metrics"}
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeStatefulSetUpdateNotRolledOut"
              "annotations" = {
                "description" = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} update has not been rolled out."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubestatefulsetupdatenotrolledout"
                "summary" = "StatefulSet update has not been rolled out."
              }
              "expr" = <<-EOT
              (
                max without (revision) (
                  kube_statefulset_status_current_revision{job="kube-state-metrics"}
                    unless
                  kube_statefulset_status_update_revision{job="kube-state-metrics"}
                )
                  *
                (
                  kube_statefulset_replicas{job="kube-state-metrics"}
                    !=
                  kube_statefulset_status_replicas_updated{job="kube-state-metrics"}
                )
              )  and (
                changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics"}[5m])
                  ==
                0
              )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeDaemonSetRolloutStuck"
              "annotations" = {
                "description" = "DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} has not finished or progressed for at least 15 minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedaemonsetrolloutstuck"
                "summary" = "DaemonSet rollout is stuck."
              }
              "expr" = <<-EOT
              (
                (
                  kube_daemonset_status_current_number_scheduled{job="kube-state-metrics"}
                   !=
                  kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"}
                ) or (
                  kube_daemonset_status_number_misscheduled{job="kube-state-metrics"}
                   !=
                  0
                ) or (
                  kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics"}
                   !=
                  kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"}
                ) or (
                  kube_daemonset_status_number_available{job="kube-state-metrics"}
                   !=
                  kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"}
                )
              ) and (
                changes(kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics"}[5m])
                  ==
                0
              )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeContainerWaiting"
              "annotations" = {
                "description" = "pod/{{ $labels.pod }} in namespace {{ $labels.namespace }} on container {{ $labels.container}} has been in waiting state for longer than 1 hour."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubecontainerwaiting"
                "summary" = "Pod container waiting longer than 1 hour"
              }
              "expr" = <<-EOT
              sum by (namespace, pod, container, cluster) (kube_pod_container_status_waiting_reason{job="kube-state-metrics"}) > 0
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeDaemonSetNotScheduled"
              "annotations" = {
                "description" = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are not scheduled."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedaemonsetnotscheduled"
                "summary" = "DaemonSet pods are not scheduled."
              }
              "expr" = <<-EOT
              kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"}
                -
              kube_daemonset_status_current_number_scheduled{job="kube-state-metrics"} > 0
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeDaemonSetMisScheduled"
              "annotations" = {
                "description" = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are running where they are not supposed to run."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedaemonsetmisscheduled"
                "summary" = "DaemonSet pods are misscheduled."
              }
              "expr" = <<-EOT
              kube_daemonset_status_number_misscheduled{job="kube-state-metrics"} > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeJobNotCompleted"
              "annotations" = {
                "description" = "Job {{ $labels.namespace }}/{{ $labels.job_name }} is taking more than {{ \"43200\" | humanizeDuration }} to complete."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubejobnotcompleted"
                "summary" = "Job did not complete in time"
              }
              "expr" = <<-EOT
              time() - max by(namespace, job_name, cluster) (kube_job_status_start_time{job="kube-state-metrics"}
                and
              kube_job_status_active{job="kube-state-metrics"} > 0) > 43200
              
              EOT
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeJobFailed"
              "annotations" = {
                "description" = "Job {{ $labels.namespace }}/{{ $labels.job_name }} failed to complete. Removing failed job after investigation should clear this alert."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubejobfailed"
                "summary" = "Job failed to complete."
              }
              "expr" = <<-EOT
              kube_job_failed{job="kube-state-metrics"}  > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeHpaReplicasMismatch"
              "annotations" = {
                "description" = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler  }} has not matched the desired number of replicas for longer than 15 minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubehpareplicasmismatch"
                "summary" = "HPA has not matched descired number of replicas."
              }
              "expr" = <<-EOT
              (kube_horizontalpodautoscaler_status_desired_replicas{job="kube-state-metrics"}
                !=
              kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"})
                and
              (kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}
                >
              kube_horizontalpodautoscaler_spec_min_replicas{job="kube-state-metrics"})
                and
              (kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}
                <
              kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics"})
                and
              changes(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}[15m]) == 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeHpaMaxedOut"
              "annotations" = {
                "description" = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler  }} has been running at max replicas for longer than 15 minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubehpamaxedout"
                "summary" = "HPA is running at max replicas"
              }
              "expr" = <<-EOT
              kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics"}
                ==
              kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics"}
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
          ]
        },
        {
          "name" = "kubernetes-resources"
          "rules" = [
            {
              "alert" = "KubeCPUOvercommit"
              "annotations" = {
                "description" = "Cluster has overcommitted CPU resource requests for Pods by {{ $value }} CPU shares and cannot tolerate node failure."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubecpuovercommit"
                "summary" = "Cluster has overcommitted CPU resource requests."
              }
              "expr" = <<-EOT
              sum(namespace_cpu:kube_pod_container_resource_requests:sum{}) - (sum(kube_node_status_allocatable{resource="cpu"}) - max(kube_node_status_allocatable{resource="cpu"})) > 0
              and
              (sum(kube_node_status_allocatable{resource="cpu"}) - max(kube_node_status_allocatable{resource="cpu"})) > 0
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeMemoryOvercommit"
              "annotations" = {
                "description" = "Cluster has overcommitted memory resource requests for Pods by {{ $value | humanize }} bytes and cannot tolerate node failure."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubememoryovercommit"
                "summary" = "Cluster has overcommitted memory resource requests."
              }
              "expr" = <<-EOT
              sum(namespace_memory:kube_pod_container_resource_requests:sum{}) - (sum(kube_node_status_allocatable{resource="memory"}) - max(kube_node_status_allocatable{resource="memory"})) > 0
              and
              (sum(kube_node_status_allocatable{resource="memory"}) - max(kube_node_status_allocatable{resource="memory"})) > 0
              
              EOT
              "for" = "10m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeCPUQuotaOvercommit"
              "annotations" = {
                "description" = "Cluster has overcommitted CPU resource requests for Namespaces."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubecpuquotaovercommit"
                "summary" = "Cluster has overcommitted CPU resource requests."
              }
              "expr" = <<-EOT
              sum(min without(resource) (kube_resourcequota{job="kube-state-metrics", type="hard", resource=~"(cpu|requests.cpu)"}))
                /
              sum(kube_node_status_allocatable{resource="cpu", job="kube-state-metrics"})
                > 1.5
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeMemoryQuotaOvercommit"
              "annotations" = {
                "description" = "Cluster has overcommitted memory resource requests for Namespaces."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubememoryquotaovercommit"
                "summary" = "Cluster has overcommitted memory resource requests."
              }
              "expr" = <<-EOT
              sum(min without(resource) (kube_resourcequota{job="kube-state-metrics", type="hard", resource=~"(memory|requests.memory)"}))
                /
              sum(kube_node_status_allocatable{resource="memory", job="kube-state-metrics"})
                > 1.5
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeQuotaAlmostFull"
              "annotations" = {
                "description" = "Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubequotaalmostfull"
                "summary" = "Namespace quota is going to be full."
              }
              "expr" = <<-EOT
              kube_resourcequota{job="kube-state-metrics", type="used"}
                / ignoring(instance, job, type)
              (kube_resourcequota{job="kube-state-metrics", type="hard"} > 0)
                > 0.9 < 1
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "info"
              }
            },
            {
              "alert" = "KubeQuotaFullyUsed"
              "annotations" = {
                "description" = "Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubequotafullyused"
                "summary" = "Namespace quota is fully used."
              }
              "expr" = <<-EOT
              kube_resourcequota{job="kube-state-metrics", type="used"}
                / ignoring(instance, job, type)
              (kube_resourcequota{job="kube-state-metrics", type="hard"} > 0)
                == 1
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "info"
              }
            },
            {
              "alert" = "KubeQuotaExceeded"
              "annotations" = {
                "description" = "Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubequotaexceeded"
                "summary" = "Namespace quota has exceeded the limits."
              }
              "expr" = <<-EOT
              kube_resourcequota{job="kube-state-metrics", type="used"}
                / ignoring(instance, job, type)
              (kube_resourcequota{job="kube-state-metrics", type="hard"} > 0)
                > 1
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "CPUThrottlingHigh"
              "annotations" = {
                "description" = "{{ $value | humanizePercentage }} throttling of CPU in namespace {{ $labels.namespace }} for container {{ $labels.container }} in pod {{ $labels.pod }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/cputhrottlinghigh"
                "summary" = "Processes experience elevated CPU throttling."
              }
              "expr" = <<-EOT
              sum(increase(container_cpu_cfs_throttled_periods_total{container!="", }[5m])) by (container, pod, namespace)
                /
              sum(increase(container_cpu_cfs_periods_total{}[5m])) by (container, pod, namespace)
                > ( 25 / 100 )
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "info"
              }
            },
          ]
        },
        {
          "name" = "kubernetes-storage"
          "rules" = [
            {
              "alert" = "KubePersistentVolumeFillingUp"
              "annotations" = {
                "description" = "The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is only {{ $value | humanizePercentage }} free."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumefillingup"
                "summary" = "PersistentVolume is filling up."
              }
              "expr" = <<-EOT
              (
                kubelet_volume_stats_available_bytes{job="kubelet", metrics_path="/metrics"}
                  /
                kubelet_volume_stats_capacity_bytes{job="kubelet", metrics_path="/metrics"}
              ) < 0.03
              and
              kubelet_volume_stats_used_bytes{job="kubelet", metrics_path="/metrics"} > 0
              unless on(namespace, persistentvolumeclaim)
              kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
              unless on(namespace, persistentvolumeclaim)
              kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
              
              EOT
              "for" = "1m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubePersistentVolumeFillingUp"
              "annotations" = {
                "description" = "Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to fill up within four days. Currently {{ $value | humanizePercentage }} is available."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumefillingup"
                "summary" = "PersistentVolume is filling up."
              }
              "expr" = <<-EOT
              (
                kubelet_volume_stats_available_bytes{job="kubelet", metrics_path="/metrics"}
                  /
                kubelet_volume_stats_capacity_bytes{job="kubelet", metrics_path="/metrics"}
              ) < 0.15
              and
              kubelet_volume_stats_used_bytes{job="kubelet", metrics_path="/metrics"} > 0
              and
              predict_linear(kubelet_volume_stats_available_bytes{job="kubelet", metrics_path="/metrics"}[6h], 4 * 24 * 3600) < 0
              unless on(namespace, persistentvolumeclaim)
              kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
              unless on(namespace, persistentvolumeclaim)
              kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubePersistentVolumeInodesFillingUp"
              "annotations" = {
                "description" = "The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} only has {{ $value | humanizePercentage }} free inodes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeinodesfillingup"
                "summary" = "PersistentVolumeInodes are filling up."
              }
              "expr" = <<-EOT
              (
                kubelet_volume_stats_inodes_free{job="kubelet", metrics_path="/metrics"}
                  /
                kubelet_volume_stats_inodes{job="kubelet", metrics_path="/metrics"}
              ) < 0.03
              and
              kubelet_volume_stats_inodes_used{job="kubelet", metrics_path="/metrics"} > 0
              unless on(namespace, persistentvolumeclaim)
              kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
              unless on(namespace, persistentvolumeclaim)
              kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
              
              EOT
              "for" = "1m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubePersistentVolumeInodesFillingUp"
              "annotations" = {
                "description" = "Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to run out of inodes within four days. Currently {{ $value | humanizePercentage }} of its inodes are free."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeinodesfillingup"
                "summary" = "PersistentVolumeInodes are filling up."
              }
              "expr" = <<-EOT
              (
                kubelet_volume_stats_inodes_free{job="kubelet", metrics_path="/metrics"}
                  /
                kubelet_volume_stats_inodes{job="kubelet", metrics_path="/metrics"}
              ) < 0.15
              and
              kubelet_volume_stats_inodes_used{job="kubelet", metrics_path="/metrics"} > 0
              and
              predict_linear(kubelet_volume_stats_inodes_free{job="kubelet", metrics_path="/metrics"}[6h], 4 * 24 * 3600) < 0
              unless on(namespace, persistentvolumeclaim)
              kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
              unless on(namespace, persistentvolumeclaim)
              kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
              
              EOT
              "for" = "1h"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubePersistentVolumeErrors"
              "annotations" = {
                "description" = "The persistent volume {{ $labels.persistentvolume }} has status {{ $labels.phase }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeerrors"
                "summary" = "PersistentVolume is having issues with provisioning."
              }
              "expr" = <<-EOT
              kube_persistentvolume_status_phase{phase=~"Failed|Pending",job="kube-state-metrics"} > 0
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "critical"
              }
            },
          ]
        },
        {
          "name" = "kubernetes-system"
          "rules" = [
            {
              "alert" = "KubeVersionMismatch"
              "annotations" = {
                "description" = "There are {{ $value }} different semantic versions of Kubernetes components running."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeversionmismatch"
                "summary" = "Different semantic versions of Kubernetes components running."
              }
              "expr" = <<-EOT
              count by (cluster) (count by (git_version, cluster) (label_replace(kubernetes_build_info{job!~"kube-dns|coredns"},"git_version","$1","git_version","(v[0-9]*.[0-9]*).*"))) > 1
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeClientErrors"
              "annotations" = {
                "description" = "Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ $value | humanizePercentage }} errors.'"
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeclienterrors"
                "summary" = "Kubernetes API server client is experiencing errors."
              }
              "expr" = <<-EOT
              (sum(rate(rest_client_requests_total{code=~"5.."}[5m])) by (cluster, instance, job, namespace)
                /
              sum(rate(rest_client_requests_total[5m])) by (cluster, instance, job, namespace))
              > 0.01
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
          ]
        },
        {
          "name" = "kube-apiserver-slos"
          "rules" = [
            {
              "alert" = "KubeAPIErrorBudgetBurn"
              "annotations" = {
                "description" = "The API server is burning too much error budget."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeapierrorbudgetburn"
                "summary" = "The API server is burning too much error budget."
              }
              "expr" = <<-EOT
              sum(apiserver_request:burnrate1h) > (14.40 * 0.01000)
              and
              sum(apiserver_request:burnrate5m) > (14.40 * 0.01000)
              
              EOT
              "for" = "2m"
              "labels" = {
                "long" = "1h"
                "severity" = "critical"
                "short" = "5m"
              }
            },
            {
              "alert" = "KubeAPIErrorBudgetBurn"
              "annotations" = {
                "description" = "The API server is burning too much error budget."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeapierrorbudgetburn"
                "summary" = "The API server is burning too much error budget."
              }
              "expr" = <<-EOT
              sum(apiserver_request:burnrate6h) > (6.00 * 0.01000)
              and
              sum(apiserver_request:burnrate30m) > (6.00 * 0.01000)
              
              EOT
              "for" = "15m"
              "labels" = {
                "long" = "6h"
                "severity" = "critical"
                "short" = "30m"
              }
            },
            {
              "alert" = "KubeAPIErrorBudgetBurn"
              "annotations" = {
                "description" = "The API server is burning too much error budget."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeapierrorbudgetburn"
                "summary" = "The API server is burning too much error budget."
              }
              "expr" = <<-EOT
              sum(apiserver_request:burnrate1d) > (3.00 * 0.01000)
              and
              sum(apiserver_request:burnrate2h) > (3.00 * 0.01000)
              
              EOT
              "for" = "1h"
              "labels" = {
                "long" = "1d"
                "severity" = "warning"
                "short" = "2h"
              }
            },
            {
              "alert" = "KubeAPIErrorBudgetBurn"
              "annotations" = {
                "description" = "The API server is burning too much error budget."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeapierrorbudgetburn"
                "summary" = "The API server is burning too much error budget."
              }
              "expr" = <<-EOT
              sum(apiserver_request:burnrate3d) > (1.00 * 0.01000)
              and
              sum(apiserver_request:burnrate6h) > (1.00 * 0.01000)
              
              EOT
              "for" = "3h"
              "labels" = {
                "long" = "3d"
                "severity" = "warning"
                "short" = "6h"
              }
            },
          ]
        },
        {
          "name" = "kubernetes-system-apiserver"
          "rules" = [
            {
              "alert" = "KubeClientCertificateExpiration"
              "annotations" = {
                "description" = "A client certificate used to authenticate to kubernetes apiserver is expiring in less than 7.0 days."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeclientcertificateexpiration"
                "summary" = "Client certificate is about to expire."
              }
              "expr" = <<-EOT
              apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and on(job) histogram_quantile(0.01, sum by (job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="apiserver"}[5m]))) < 604800
              
              EOT
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeClientCertificateExpiration"
              "annotations" = {
                "description" = "A client certificate used to authenticate to kubernetes apiserver is expiring in less than 24.0 hours."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeclientcertificateexpiration"
                "summary" = "Client certificate is about to expire."
              }
              "expr" = <<-EOT
              apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and on(job) histogram_quantile(0.01, sum by (job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="apiserver"}[5m]))) < 86400
              
              EOT
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubeAggregatedAPIErrors"
              "annotations" = {
                "description" = "Kubernetes aggregated API {{ $labels.name }}/{{ $labels.namespace }} has reported errors. It has appeared unavailable {{ $value | humanize }} times averaged over the past 10m."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeaggregatedapierrors"
                "summary" = "Kubernetes aggregated API has reported errors."
              }
              "expr" = <<-EOT
              sum by(name, namespace, cluster)(increase(aggregator_unavailable_apiservice_total[10m])) > 4
              
              EOT
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeAggregatedAPIDown"
              "annotations" = {
                "description" = "Kubernetes aggregated API {{ $labels.name }}/{{ $labels.namespace }} has been only {{ $value | humanize }}% available over the last 10m."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeaggregatedapidown"
                "summary" = "Kubernetes aggregated API is down."
              }
              "expr" = <<-EOT
              (1 - max by(name, namespace, cluster)(avg_over_time(aggregator_unavailable_apiservice[10m]))) * 100 < 85
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeAPIDown"
              "annotations" = {
                "description" = "KubeAPI has disappeared from Prometheus target discovery."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeapidown"
                "summary" = "Target disappeared from Prometheus target discovery."
              }
              "expr" = <<-EOT
              absent(up{job="apiserver"} == 1)
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubeAPITerminatedRequests"
              "annotations" = {
                "description" = "The kubernetes apiserver has terminated {{ $value | humanizePercentage }} of its incoming requests."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeapiterminatedrequests"
                "summary" = "The kubernetes apiserver has terminated {{ $value | humanizePercentage }} of its incoming requests."
              }
              "expr" = <<-EOT
              sum(rate(apiserver_request_terminations_total{job="apiserver"}[10m]))  / (  sum(rate(apiserver_request_total{job="apiserver"}[10m])) + sum(rate(apiserver_request_terminations_total{job="apiserver"}[10m])) ) > 0.20
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "warning"
              }
            },
          ]
        },
        {
          "name" = "kubernetes-system-kubelet"
          "rules" = [
            {
              "alert" = "KubeNodeNotReady"
              "annotations" = {
                "description" = "{{ $labels.node }} has been unready for more than 15 minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubenodenotready"
                "summary" = "Node is not ready."
              }
              "expr" = <<-EOT
              kube_node_status_condition{job="kube-state-metrics",condition="Ready",status="true"} == 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeNodeUnreachable"
              "annotations" = {
                "description" = "{{ $labels.node }} is unreachable and some workloads may be rescheduled."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubenodeunreachable"
                "summary" = "Node is unreachable."
              }
              "expr" = <<-EOT
              (kube_node_spec_taint{job="kube-state-metrics",key="node.kubernetes.io/unreachable",effect="NoSchedule"} unless ignoring(key,value) kube_node_spec_taint{job="kube-state-metrics",key=~"ToBeDeletedByClusterAutoscaler|cloud.google.com/impending-node-termination|aws-node-termination-handler/spot-itn"}) == 1
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeletTooManyPods"
              "annotations" = {
                "description" = "Kubelet '{{ $labels.node }}' is running at {{ $value | humanizePercentage }} of its Pod capacity."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubelettoomanypods"
                "summary" = "Kubelet is running at capacity."
              }
              "expr" = <<-EOT
              count by(cluster, node) (
                (kube_pod_status_phase{job="kube-state-metrics",phase="Running"} == 1) * on(instance,pod,namespace,cluster) group_left(node) topk by(instance,pod,namespace,cluster) (1, kube_pod_info{job="kube-state-metrics"})
              )
              /
              max by(cluster, node) (
                kube_node_status_capacity{job="kube-state-metrics",resource="pods"} != 1
              ) > 0.95
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "info"
              }
            },
            {
              "alert" = "KubeNodeReadinessFlapping"
              "annotations" = {
                "description" = "The readiness status of node {{ $labels.node }} has changed {{ $value }} times in the last 15 minutes."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubenodereadinessflapping"
                "summary" = "Node readiness status is flapping."
              }
              "expr" = <<-EOT
              sum(changes(kube_node_status_condition{status="true",condition="Ready"}[15m])) by (cluster, node) > 2
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeletPlegDurationHigh"
              "annotations" = {
                "description" = "The Kubelet Pod Lifecycle Event Generator has a 99th percentile duration of {{ $value }} seconds on node {{ $labels.node }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletplegdurationhigh"
                "summary" = "Kubelet Pod Lifecycle Event Generator is taking too long to relist."
              }
              "expr" = <<-EOT
              node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile{quantile="0.99"} >= 10
              
              EOT
              "for" = "5m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeletPodStartUpLatencyHigh"
              "annotations" = {
                "description" = "Kubelet Pod startup 99th percentile latency is {{ $value }} seconds on node {{ $labels.node }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletpodstartuplatencyhigh"
                "summary" = "Kubelet Pod startup latency is too high."
              }
              "expr" = <<-EOT
              histogram_quantile(0.99, sum(rate(kubelet_pod_worker_duration_seconds_bucket{job="kubelet", metrics_path="/metrics"}[5m])) by (cluster, instance, le)) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet", metrics_path="/metrics"} > 60
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeletClientCertificateExpiration"
              "annotations" = {
                "description" = "Client certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletclientcertificateexpiration"
                "summary" = "Kubelet client certificate is about to expire."
              }
              "expr" = <<-EOT
              kubelet_certificate_manager_client_ttl_seconds < 604800
              
              EOT
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeletClientCertificateExpiration"
              "annotations" = {
                "description" = "Client certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletclientcertificateexpiration"
                "summary" = "Kubelet client certificate is about to expire."
              }
              "expr" = <<-EOT
              kubelet_certificate_manager_client_ttl_seconds < 86400
              
              EOT
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubeletServerCertificateExpiration"
              "annotations" = {
                "description" = "Server certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletservercertificateexpiration"
                "summary" = "Kubelet server certificate is about to expire."
              }
              "expr" = <<-EOT
              kubelet_certificate_manager_server_ttl_seconds < 604800
              
              EOT
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeletServerCertificateExpiration"
              "annotations" = {
                "description" = "Server certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletservercertificateexpiration"
                "summary" = "Kubelet server certificate is about to expire."
              }
              "expr" = <<-EOT
              kubelet_certificate_manager_server_ttl_seconds < 86400
              
              EOT
              "labels" = {
                "severity" = "critical"
              }
            },
            {
              "alert" = "KubeletClientCertificateRenewalErrors"
              "annotations" = {
                "description" = "Kubelet on node {{ $labels.node }} has failed to renew its client certificate ({{ $value | humanize }} errors in the last 5 minutes)."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletclientcertificaterenewalerrors"
                "summary" = "Kubelet has failed to renew its client certificate."
              }
              "expr" = <<-EOT
              increase(kubelet_certificate_manager_client_expiration_renew_errors[5m]) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeletServerCertificateRenewalErrors"
              "annotations" = {
                "description" = "Kubelet on node {{ $labels.node }} has failed to renew its server certificate ({{ $value | humanize }} errors in the last 5 minutes)."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletservercertificaterenewalerrors"
                "summary" = "Kubelet has failed to renew its server certificate."
              }
              "expr" = <<-EOT
              increase(kubelet_server_expiration_renew_errors[5m]) > 0
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "warning"
              }
            },
            {
              "alert" = "KubeletDown"
              "annotations" = {
                "description" = "Kubelet has disappeared from Prometheus target discovery."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeletdown"
                "summary" = "Target disappeared from Prometheus target discovery."
              }
              "expr" = <<-EOT
              absent(up{job="kubelet", metrics_path="/metrics"} == 1)
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
          ]
        },
        {
          "name" = "kubernetes-system-scheduler"
          "rules" = [
            {
              "alert" = "KubeSchedulerDown"
              "annotations" = {
                "description" = "KubeScheduler has disappeared from Prometheus target discovery."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubeschedulerdown"
                "summary" = "Target disappeared from Prometheus target discovery."
              }
              "expr" = <<-EOT
              absent(up{job="kube-scheduler"} == 1)
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
          ]
        },
        {
          "name" = "kubernetes-system-controller-manager"
          "rules" = [
            {
              "alert" = "KubeControllerManagerDown"
              "annotations" = {
                "description" = "KubeControllerManager has disappeared from Prometheus target discovery."
                "runbook_url" = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubecontrollermanagerdown"
                "summary" = "Target disappeared from Prometheus target discovery."
              }
              "expr" = <<-EOT
              absent(up{job="kube-controller-manager"} == 1)
              
              EOT
              "for" = "15m"
              "labels" = {
                "severity" = "critical"
              }
            },
          ]
        },
        {
          "name" = "kube-apiserver-burnrate.rules"
          "rules" = [
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[1d]))
                  -
                  (
                    (
                      sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le="1"}[1d]))
                      or
                      vector(0)
                    )
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le="5"}[1d]))
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le="30"}[1d]))
                  )
                )
                +
                # errors
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET",code=~"5.."}[1d]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[1d]))
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "apiserver_request:burnrate1d"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[1h]))
                  -
                  (
                    (
                      sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le="1"}[1h]))
                      or
                      vector(0)
                    )
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le="5"}[1h]))
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le="30"}[1h]))
                  )
                )
                +
                # errors
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET",code=~"5.."}[1h]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[1h]))
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "apiserver_request:burnrate1h"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[2h]))
                  -
                  (
                    (
                      sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le="1"}[2h]))
                      or
                      vector(0)
                    )
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le="5"}[2h]))
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le="30"}[2h]))
                  )
                )
                +
                # errors
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET",code=~"5.."}[2h]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[2h]))
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "apiserver_request:burnrate2h"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[30m]))
                  -
                  (
                    (
                      sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le="1"}[30m]))
                      or
                      vector(0)
                    )
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le="5"}[30m]))
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le="30"}[30m]))
                  )
                )
                +
                # errors
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET",code=~"5.."}[30m]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[30m]))
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "apiserver_request:burnrate30m"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[3d]))
                  -
                  (
                    (
                      sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le="1"}[3d]))
                      or
                      vector(0)
                    )
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le="5"}[3d]))
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le="30"}[3d]))
                  )
                )
                +
                # errors
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET",code=~"5.."}[3d]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[3d]))
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "apiserver_request:burnrate3d"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[5m]))
                  -
                  (
                    (
                      sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le="1"}[5m]))
                      or
                      vector(0)
                    )
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le="5"}[5m]))
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le="30"}[5m]))
                  )
                )
                +
                # errors
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET",code=~"5.."}[5m]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[5m]))
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "apiserver_request:burnrate5m"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[6h]))
                  -
                  (
                    (
                      sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope=~"resource|",le="1"}[6h]))
                      or
                      vector(0)
                    )
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="namespace",le="5"}[6h]))
                    +
                    sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward",scope="cluster",le="30"}[6h]))
                  )
                )
                +
                # errors
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET",code=~"5.."}[6h]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[6h]))
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "apiserver_request:burnrate6h"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[1d]))
                  -
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le="1"}[1d]))
                )
                +
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[1d]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1d]))
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "apiserver_request:burnrate1d"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[1h]))
                  -
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le="1"}[1h]))
                )
                +
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[1h]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1h]))
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "apiserver_request:burnrate1h"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[2h]))
                  -
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le="1"}[2h]))
                )
                +
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[2h]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[2h]))
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "apiserver_request:burnrate2h"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[30m]))
                  -
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le="1"}[30m]))
                )
                +
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[30m]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[30m]))
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "apiserver_request:burnrate30m"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[3d]))
                  -
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le="1"}[3d]))
                )
                +
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[3d]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[3d]))
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "apiserver_request:burnrate3d"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[5m]))
                  -
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le="1"}[5m]))
                )
                +
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[5m]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[5m]))
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "apiserver_request:burnrate5m"
            },
            {
              "expr" = <<-EOT
              (
                (
                  # too slow
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[6h]))
                  -
                  sum by (cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward",le="1"}[6h]))
                )
                +
                sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",code=~"5.."}[6h]))
              )
              /
              sum by (cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[6h]))
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "apiserver_request:burnrate6h"
            },
          ]
        },
        {
          "name" = "kube-apiserver-histogram.rules"
          "rules" = [
            {
              "expr" = <<-EOT
              histogram_quantile(0.99, sum by (cluster, le, resource) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[5m]))) > 0
              
              EOT
              "labels" = {
                "quantile" = "0.99"
                "verb" = "read"
              }
              "record" = "cluster_quantile:apiserver_request_slo_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.99, sum by (cluster, le, resource) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[5m]))) > 0
              
              EOT
              "labels" = {
                "quantile" = "0.99"
                "verb" = "write"
              }
              "record" = "cluster_quantile:apiserver_request_slo_duration_seconds:histogram_quantile"
            },
          ]
        },
        {
          "interval" = "3m"
          "name" = "kube-apiserver-availability.rules"
          "rules" = [
            {
              "expr" = <<-EOT
              avg_over_time(code_verb:apiserver_request_total:increase1h[30d]) * 24 * 30
              
              EOT
              "record" = "code_verb:apiserver_request_total:increase30d"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~"LIST|GET"})
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "code:apiserver_request_total:increase30d"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "code:apiserver_request_total:increase30d"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, verb, scope) (increase(apiserver_request_slo_duration_seconds_count[1h]))
              
              EOT
              "record" = "cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase1h"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, verb, scope) (avg_over_time(cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase1h[30d]) * 24 * 30)
              
              EOT
              "record" = "cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase30d"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, verb, scope, le) (increase(apiserver_request_slo_duration_seconds_bucket[1h]))
              
              EOT
              "record" = "cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase1h"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, verb, scope, le) (avg_over_time(cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase1h[30d]) * 24 * 30)
              
              EOT
              "record" = "cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d"
            },
            {
              "expr" = <<-EOT
              1 - (
                (
                  # write too slow
                  sum by (cluster) (cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
                  -
                  sum by (cluster) (cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d{verb=~"POST|PUT|PATCH|DELETE",le="1"})
                ) +
                (
                  # read too slow
                  sum by (cluster) (cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase30d{verb=~"LIST|GET"})
                  -
                  (
                    (
                      sum by (cluster) (cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope=~"resource|",le="1"})
                      or
                      vector(0)
                    )
                    +
                    sum by (cluster) (cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="namespace",le="5"})
                    +
                    sum by (cluster) (cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="cluster",le="30"})
                  )
                ) +
                # errors
                sum by (cluster) (code:apiserver_request_total:increase30d{code=~"5.."} or vector(0))
              )
              /
              sum by (cluster) (code:apiserver_request_total:increase30d)
              
              EOT
              "labels" = {
                "verb" = "all"
              }
              "record" = "apiserver_request:availability30d"
            },
            {
              "expr" = <<-EOT
              1 - (
                sum by (cluster) (cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase30d{verb=~"LIST|GET"})
                -
                (
                  # too slow
                  (
                    sum by (cluster) (cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope=~"resource|",le="1"})
                    or
                    vector(0)
                  )
                  +
                  sum by (cluster) (cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="namespace",le="5"})
                  +
                  sum by (cluster) (cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="cluster",le="30"})
                )
                +
                # errors
                sum by (cluster) (code:apiserver_request_total:increase30d{verb="read",code=~"5.."} or vector(0))
              )
              /
              sum by (cluster) (code:apiserver_request_total:increase30d{verb="read"})
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "apiserver_request:availability30d"
            },
            {
              "expr" = <<-EOT
              1 - (
                (
                  # too slow
                  sum by (cluster) (cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
                  -
                  sum by (cluster) (cluster_verb_scope_le:apiserver_request_slo_duration_seconds_bucket:increase30d{verb=~"POST|PUT|PATCH|DELETE",le="1"})
                )
                +
                # errors
                sum by (cluster) (code:apiserver_request_total:increase30d{verb="write",code=~"5.."} or vector(0))
              )
              /
              sum by (cluster) (code:apiserver_request_total:increase30d{verb="write"})
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "apiserver_request:availability30d"
            },
            {
              "expr" = <<-EOT
              sum by (cluster,code,resource) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[5m]))
              
              EOT
              "labels" = {
                "verb" = "read"
              }
              "record" = "code_resource:apiserver_request_total:rate5m"
            },
            {
              "expr" = <<-EOT
              sum by (cluster,code,resource) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[5m]))
              
              EOT
              "labels" = {
                "verb" = "write"
              }
              "record" = "code_resource:apiserver_request_total:rate5m"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"2.."}[1h]))
              
              EOT
              "record" = "code_verb:apiserver_request_total:increase1h"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"3.."}[1h]))
              
              EOT
              "record" = "code_verb:apiserver_request_total:increase1h"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"4.."}[1h]))
              
              EOT
              "record" = "code_verb:apiserver_request_total:increase1h"
            },
            {
              "expr" = <<-EOT
              sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"5.."}[1h]))
              
              EOT
              "record" = "code_verb:apiserver_request_total:increase1h"
            },
          ]
        },
        {
          "name" = "k8s.rules"
          "rules" = [
            {
              "expr" = <<-EOT
              sum by (cluster, namespace, pod, container) (
                irate(container_cpu_usage_seconds_total{job="kubelet", metrics_path="/metrics/cadvisor", image!=""}[5m])
              ) * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (
                1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""})
              )
              
              EOT
              "record" = "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate"
            },
            {
              "expr" = <<-EOT
              container_memory_working_set_bytes{job="kubelet", metrics_path="/metrics/cadvisor", image!=""}
              * on (namespace, pod) group_left(node) topk by(namespace, pod) (1,
                max by(namespace, pod, node) (kube_pod_info{node!=""})
              )
              
              EOT
              "record" = "node_namespace_pod_container:container_memory_working_set_bytes"
            },
            {
              "expr" = <<-EOT
              container_memory_rss{job="kubelet", metrics_path="/metrics/cadvisor", image!=""}
              * on (namespace, pod) group_left(node) topk by(namespace, pod) (1,
                max by(namespace, pod, node) (kube_pod_info{node!=""})
              )
              
              EOT
              "record" = "node_namespace_pod_container:container_memory_rss"
            },
            {
              "expr" = <<-EOT
              container_memory_cache{job="kubelet", metrics_path="/metrics/cadvisor", image!=""}
              * on (namespace, pod) group_left(node) topk by(namespace, pod) (1,
                max by(namespace, pod, node) (kube_pod_info{node!=""})
              )
              
              EOT
              "record" = "node_namespace_pod_container:container_memory_cache"
            },
            {
              "expr" = <<-EOT
              container_memory_swap{job="kubelet", metrics_path="/metrics/cadvisor", image!=""}
              * on (namespace, pod) group_left(node) topk by(namespace, pod) (1,
                max by(namespace, pod, node) (kube_pod_info{node!=""})
              )
              
              EOT
              "record" = "node_namespace_pod_container:container_memory_swap"
            },
            {
              "expr" = <<-EOT
              kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)
              group_left() max by (namespace, pod, cluster) (
                (kube_pod_status_phase{phase=~"Pending|Running"} == 1)
              )
              
              EOT
              "record" = "cluster:namespace:pod_memory:active:kube_pod_container_resource_requests"
            },
            {
              "expr" = <<-EOT
              sum by (namespace, cluster) (
                  sum by (namespace, pod, cluster) (
                      max by (namespace, pod, container, cluster) (
                        kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}
                      ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (
                        kube_pod_status_phase{phase=~"Pending|Running"} == 1
                      )
                  )
              )
              
              EOT
              "record" = "namespace_memory:kube_pod_container_resource_requests:sum"
            },
            {
              "expr" = <<-EOT
              kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)
              group_left() max by (namespace, pod, cluster) (
                (kube_pod_status_phase{phase=~"Pending|Running"} == 1)
              )
              
              EOT
              "record" = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests"
            },
            {
              "expr" = <<-EOT
              sum by (namespace, cluster) (
                  sum by (namespace, pod, cluster) (
                      max by (namespace, pod, container, cluster) (
                        kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}
                      ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (
                        kube_pod_status_phase{phase=~"Pending|Running"} == 1
                      )
                  )
              )
              
              EOT
              "record" = "namespace_cpu:kube_pod_container_resource_requests:sum"
            },
            {
              "expr" = <<-EOT
              kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)
              group_left() max by (namespace, pod, cluster) (
                (kube_pod_status_phase{phase=~"Pending|Running"} == 1)
              )
              
              EOT
              "record" = "cluster:namespace:pod_memory:active:kube_pod_container_resource_limits"
            },
            {
              "expr" = <<-EOT
              sum by (namespace, cluster) (
                  sum by (namespace, pod, cluster) (
                      max by (namespace, pod, container, cluster) (
                        kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}
                      ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (
                        kube_pod_status_phase{phase=~"Pending|Running"} == 1
                      )
                  )
              )
              
              EOT
              "record" = "namespace_memory:kube_pod_container_resource_limits:sum"
            },
            {
              "expr" = <<-EOT
              kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)
              group_left() max by (namespace, pod, cluster) (
               (kube_pod_status_phase{phase=~"Pending|Running"} == 1)
               )
              
              EOT
              "record" = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits"
            },
            {
              "expr" = <<-EOT
              sum by (namespace, cluster) (
                  sum by (namespace, pod, cluster) (
                      max by (namespace, pod, container, cluster) (
                        kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}
                      ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (
                        kube_pod_status_phase{phase=~"Pending|Running"} == 1
                      )
                  )
              )
              
              EOT
              "record" = "namespace_cpu:kube_pod_container_resource_limits:sum"
            },
            {
              "expr" = <<-EOT
              max by (cluster, namespace, workload, pod) (
                label_replace(
                  label_replace(
                    kube_pod_owner{job="kube-state-metrics", owner_kind="ReplicaSet"},
                    "replicaset", "$1", "owner_name", "(.*)"
                  ) * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (
                    1, max by (replicaset, namespace, owner_name) (
                      kube_replicaset_owner{job="kube-state-metrics"}
                    )
                  ),
                  "workload", "$1", "owner_name", "(.*)"
                )
              )
              
              EOT
              "labels" = {
                "workload_type" = "deployment"
              }
              "record" = "namespace_workload_pod:kube_pod_owner:relabel"
            },
            {
              "expr" = <<-EOT
              max by (cluster, namespace, workload, pod) (
                label_replace(
                  kube_pod_owner{job="kube-state-metrics", owner_kind="DaemonSet"},
                  "workload", "$1", "owner_name", "(.*)"
                )
              )
              
              EOT
              "labels" = {
                "workload_type" = "daemonset"
              }
              "record" = "namespace_workload_pod:kube_pod_owner:relabel"
            },
            {
              "expr" = <<-EOT
              max by (cluster, namespace, workload, pod) (
                label_replace(
                  kube_pod_owner{job="kube-state-metrics", owner_kind="StatefulSet"},
                  "workload", "$1", "owner_name", "(.*)"
                )
              )
              
              EOT
              "labels" = {
                "workload_type" = "statefulset"
              }
              "record" = "namespace_workload_pod:kube_pod_owner:relabel"
            },
            {
              "expr" = <<-EOT
              max by (cluster, namespace, workload, pod) (
                label_replace(
                  kube_pod_owner{job="kube-state-metrics", owner_kind="Job"},
                  "workload", "$1", "owner_name", "(.*)"
                )
              )
              
              EOT
              "labels" = {
                "workload_type" = "job"
              }
              "record" = "namespace_workload_pod:kube_pod_owner:relabel"
            },
          ]
        },
        {
          "name" = "kube-scheduler.rules"
          "rules" = [
            {
              "expr" = <<-EOT
              histogram_quantile(0.99, sum(rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.99"
              }
              "record" = "cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.99, sum(rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.99"
              }
              "record" = "cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.99, sum(rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.99"
              }
              "record" = "cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.9, sum(rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.9"
              }
              "record" = "cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.9, sum(rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.9"
              }
              "record" = "cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.9, sum(rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.9"
              }
              "record" = "cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.5, sum(rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.5"
              }
              "record" = "cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.5, sum(rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.5"
              }
              "record" = "cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.5, sum(rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])) without(instance, pod))
              
              EOT
              "labels" = {
                "quantile" = "0.5"
              }
              "record" = "cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile"
            },
          ]
        },
        {
          "name" = "node.rules"
          "rules" = [
            {
              "expr" = <<-EOT
              topk by(cluster, namespace, pod) (1,
                max by (cluster, node, namespace, pod) (
                  label_replace(kube_pod_info{job="kube-state-metrics",node!=""}, "pod", "$1", "pod", "(.*)")
              ))
              
              EOT
              "record" = "node_namespace_pod:kube_pod_info:"
            },
            {
              "expr" = <<-EOT
              count by (cluster, node) (sum by (node, cpu) (
                node_cpu_seconds_total{job="node-exporter"}
              * on (namespace, pod) group_left(node)
                topk by(namespace, pod) (1, node_namespace_pod:kube_pod_info:)
              ))
              
              EOT
              "record" = "node:node_num_cpu:sum"
            },
            {
              "expr" = <<-EOT
              sum(
                node_memory_MemAvailable_bytes{job="node-exporter"} or
                (
                  node_memory_Buffers_bytes{job="node-exporter"} +
                  node_memory_Cached_bytes{job="node-exporter"} +
                  node_memory_MemFree_bytes{job="node-exporter"} +
                  node_memory_Slab_bytes{job="node-exporter"}
                )
              ) by (cluster)
              
              EOT
              "record" = ":node_memory_MemAvailable_bytes:sum"
            },
            {
              "expr" = <<-EOT
              sum(rate(node_cpu_seconds_total{job="node-exporter",mode!="idle",mode!="iowait",mode!="steal"}[5m])) /
              count(sum(node_cpu_seconds_total{job="node-exporter"}) by (cluster, instance, cpu))
              
              EOT
              "record" = "cluster:node_cpu:ratio_rate5m"
            },
          ]
        },
        {
          "name" = "kubelet.rules"
          "rules" = [
            {
              "expr" = <<-EOT
              histogram_quantile(0.99, sum(rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) by (cluster, instance, le) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet", metrics_path="/metrics"})
              
              EOT
              "labels" = {
                "quantile" = "0.99"
              }
              "record" = "node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.9, sum(rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) by (cluster, instance, le) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet", metrics_path="/metrics"})
              
              EOT
              "labels" = {
                "quantile" = "0.9"
              }
              "record" = "node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile"
            },
            {
              "expr" = <<-EOT
              histogram_quantile(0.5, sum(rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) by (cluster, instance, le) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet", metrics_path="/metrics"})
              
              EOT
              "labels" = {
                "quantile" = "0.5"
              }
              "record" = "node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile"
            },
          ]
        },
      ]
    }
  }
  depends_on = [module.setup]
}