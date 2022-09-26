# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./nodeExporter-daemonset.yaml

resource "kubernetes_manifest" "daemonset_monitoring_node_exporter" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "DaemonSet"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "node-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "1.3.1"
      }
      "name" = "node-exporter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "exporter"
          "app.kubernetes.io/name" = "node-exporter"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "kubectl.kubernetes.io/default-container" = "node-exporter"
          }
          "labels" = {
            "app.kubernetes.io/component" = "exporter"
            "app.kubernetes.io/name" = "node-exporter"
            "app.kubernetes.io/part-of" = "kube-prometheus"
            "app.kubernetes.io/version" = "1.3.1"
          }
        }
        "spec" = {
          "automountServiceAccountToken" = true
          "containers" = [
            {
              "args" = [
                "--web.listen-address=127.0.0.1:9100",
                "--path.sysfs=/host/sys",
                "--path.rootfs=/host/root",
                "--no-collector.wifi",
                "--no-collector.hwmon",
                "--collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run/k3s/containerd/.+|var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)",
                "--collector.netclass.ignored-devices=^(veth.*|[a-f0-9]{15})$",
                "--collector.netdev.device-exclude=^(veth.*|[a-f0-9]{15})$",
              ]
              "image" = "quay.io/prometheus/node-exporter:v1.3.1"
              "name" = "node-exporter"
              "resources" = {
                "limits" = {
                  "cpu" = "250m"
                  "memory" = "180Mi"
                }
                "requests" = {
                  "cpu" = "102m"
                  "memory" = "180Mi"
                }
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "capabilities" = {
                  "add" = [
                    "SYS_TIME",
                  ]
                  "drop" = [
                    "ALL",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/host/sys"
                  "mountPropagation" = "HostToContainer"
                  "name" = "sys"
                  "readOnly" = true
                },
                {
                  "mountPath" = "/host/root"
                  "mountPropagation" = "HostToContainer"
                  "name" = "root"
                  "readOnly" = true
                },
              ]
            },
            {
              "args" = [
                "--logtostderr",
                "--secure-listen-address=[$(IP)]:9100",
                "--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
                "--upstream=http://127.0.0.1:9100/",
              ]
              "env" = [
                {
                  "name" = "IP"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "status.podIP"
                    }
                  }
                },
              ]
              "image" = "quay.io/brancz/kube-rbac-proxy:v0.12.0"
              "name" = "kube-rbac-proxy"
              "ports" = [
                {
                  "containerPort" = 9100
                  "hostPort" = 9100
                  "name" = "https"
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "20m"
                  "memory" = "40Mi"
                }
                "requests" = {
                  "cpu" = "10m"
                  "memory" = "20Mi"
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
                "runAsGroup" = 65532
                "runAsNonRoot" = true
                "runAsUser" = 65532
              }
            },
          ]
          "hostNetwork" = true
          "hostPID" = true
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "priorityClassName" = "system-cluster-critical"
          "securityContext" = {
            "runAsNonRoot" = true
            "runAsUser" = 65534
          }
          "serviceAccountName" = "node-exporter"
          "tolerations" = [
            {
              "operator" = "Exists"
            },
          ]
          "volumes" = [
            {
              "hostPath" = {
                "path" = "/sys"
              }
              "name" = "sys"
            },
            {
              "hostPath" = {
                "path" = "/"
              }
              "name" = "root"
            },
          ]
        }
      }
      "updateStrategy" = {
        "rollingUpdate" = {
          "maxUnavailable" = "10%"
        }
        "type" = "RollingUpdate"
      }
    }
  }
  depends_on = [module.setup]
}