# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./grafana-deployment.yaml

resource "kubernetes_manifest" "deployment_monitoring_grafana" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "grafana"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "8.5.5"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "grafana"
          "app.kubernetes.io/name" = "grafana"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "checksum/grafana-config" = "4d376802c61554030cfd50d569dabda7"
            "checksum/grafana-dashboardproviders" = "2d9c006bd11b55212fbb797fdc6d153b"
            "checksum/grafana-datasources" = "efad9cbfdaacad9fdecdff58cc032954"
          }
          "labels" = {
            "app.kubernetes.io/component" = "grafana"
            "app.kubernetes.io/name" = "grafana"
            "app.kubernetes.io/part-of" = "kube-prometheus"
            "app.kubernetes.io/version" = "8.5.5"
          }
        }
        "spec" = {
          "automountServiceAccountToken" = false
          "containers" = [
            {
              # "env" = []
              "image" = "grafana/grafana:8.5.5"
              "name" = "grafana"
              "ports" = [
                {
                  "containerPort" = 3000
                  "name" = "http"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/api/health"
                  "port" = "http"
                }
              }
              "resources" = {
                "limits" = {
                  "cpu" = "200m"
                  "memory" = "200Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "100Mi"
                }
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "capabilities" = {
                  "drop" = [
                    "ALL",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/grafana"
                  "name" = "grafana-storage"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/etc/grafana/provisioning/datasources"
                  "name" = "grafana-datasources"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/etc/grafana/provisioning/dashboards"
                  "name" = "grafana-dashboards"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-plugins"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/alertmanager-overview"
                  "name" = "grafana-dashboard-alertmanager-overview"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/apiserver"
                  "name" = "grafana-dashboard-apiserver"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/cluster-total"
                  "name" = "grafana-dashboard-cluster-total"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/controller-manager"
                  "name" = "grafana-dashboard-controller-manager"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/grafana-overview"
                  "name" = "grafana-dashboard-grafana-overview"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/k8s-resources-cluster"
                  "name" = "grafana-dashboard-k8s-resources-cluster"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/k8s-resources-namespace"
                  "name" = "grafana-dashboard-k8s-resources-namespace"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/k8s-resources-node"
                  "name" = "grafana-dashboard-k8s-resources-node"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/k8s-resources-pod"
                  "name" = "grafana-dashboard-k8s-resources-pod"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/k8s-resources-workload"
                  "name" = "grafana-dashboard-k8s-resources-workload"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/k8s-resources-workloads-namespace"
                  "name" = "grafana-dashboard-k8s-resources-workloads-namespace"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/kubelet"
                  "name" = "grafana-dashboard-kubelet"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/namespace-by-pod"
                  "name" = "grafana-dashboard-namespace-by-pod"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/namespace-by-workload"
                  "name" = "grafana-dashboard-namespace-by-workload"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/node-cluster-rsrc-use"
                  "name" = "grafana-dashboard-node-cluster-rsrc-use"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/node-rsrc-use"
                  "name" = "grafana-dashboard-node-rsrc-use"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/nodes"
                  "name" = "grafana-dashboard-nodes"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/persistentvolumesusage"
                  "name" = "grafana-dashboard-persistentvolumesusage"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/pod-total"
                  "name" = "grafana-dashboard-pod-total"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/prometheus-remote-write"
                  "name" = "grafana-dashboard-prometheus-remote-write"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/prometheus"
                  "name" = "grafana-dashboard-prometheus"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/proxy"
                  "name" = "grafana-dashboard-proxy"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/scheduler"
                  "name" = "grafana-dashboard-scheduler"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/grafana-dashboard-definitions/0/workload-total"
                  "name" = "grafana-dashboard-workload-total"
                  # "readOnly" = false
                },
                {
                  "mountPath" = "/etc/grafana"
                  "name" = "grafana-config"
                  # "readOnly" = false
                },
              ]
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "securityContext" = {
            "fsGroup" = 65534
            "runAsNonRoot" = true
            "runAsUser" = 65534
          }
          "serviceAccountName" = "grafana"
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "grafana-storage"
            },
            {
              "name" = "grafana-datasources"
              "secret" = {
                "secretName" = "grafana-datasources"
              }
            },
            {
              "configMap" = {
                "name" = "grafana-dashboards"
              }
              "name" = "grafana-dashboards"
            },
            {
              "emptyDir" = {
                "medium" = "Memory"
              }
              "name" = "tmp-plugins"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-alertmanager-overview"
              }
              "name" = "grafana-dashboard-alertmanager-overview"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-apiserver"
              }
              "name" = "grafana-dashboard-apiserver"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-cluster-total"
              }
              "name" = "grafana-dashboard-cluster-total"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-controller-manager"
              }
              "name" = "grafana-dashboard-controller-manager"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-grafana-overview"
              }
              "name" = "grafana-dashboard-grafana-overview"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-k8s-resources-cluster"
              }
              "name" = "grafana-dashboard-k8s-resources-cluster"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-k8s-resources-namespace"
              }
              "name" = "grafana-dashboard-k8s-resources-namespace"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-k8s-resources-node"
              }
              "name" = "grafana-dashboard-k8s-resources-node"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-k8s-resources-pod"
              }
              "name" = "grafana-dashboard-k8s-resources-pod"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-k8s-resources-workload"
              }
              "name" = "grafana-dashboard-k8s-resources-workload"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-k8s-resources-workloads-namespace"
              }
              "name" = "grafana-dashboard-k8s-resources-workloads-namespace"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-kubelet"
              }
              "name" = "grafana-dashboard-kubelet"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-namespace-by-pod"
              }
              "name" = "grafana-dashboard-namespace-by-pod"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-namespace-by-workload"
              }
              "name" = "grafana-dashboard-namespace-by-workload"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-node-cluster-rsrc-use"
              }
              "name" = "grafana-dashboard-node-cluster-rsrc-use"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-node-rsrc-use"
              }
              "name" = "grafana-dashboard-node-rsrc-use"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-nodes"
              }
              "name" = "grafana-dashboard-nodes"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-persistentvolumesusage"
              }
              "name" = "grafana-dashboard-persistentvolumesusage"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-pod-total"
              }
              "name" = "grafana-dashboard-pod-total"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-prometheus-remote-write"
              }
              "name" = "grafana-dashboard-prometheus-remote-write"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-prometheus"
              }
              "name" = "grafana-dashboard-prometheus"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-proxy"
              }
              "name" = "grafana-dashboard-proxy"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-scheduler"
              }
              "name" = "grafana-dashboard-scheduler"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboard-workload-total"
              }
              "name" = "grafana-dashboard-workload-total"
            },
            {
              "name" = "grafana-config"
              "secret" = {
                "secretName" = "grafana-config"
              }
            },
          ]
        }
      }
    }
  }
  depends_on = [module.setup]
}
