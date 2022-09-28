# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/blackboxExporter-deployment.yaml

resource "kubernetes_manifest" "deployment_monitoring_blackbox_exporter" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "blackbox-exporter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.21.0"
      }
      "name" = "blackbox-exporter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "exporter"
          "app.kubernetes.io/name" = "blackbox-exporter"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "kubectl.kubernetes.io/default-container" = "blackbox-exporter"
          }
          "labels" = {
            "app.kubernetes.io/component" = "exporter"
            "app.kubernetes.io/name" = "blackbox-exporter"
            "app.kubernetes.io/part-of" = "kube-prometheus"
            "app.kubernetes.io/version" = "0.21.0"
          }
        }
        "spec" = {
          "automountServiceAccountToken" = true
          "containers" = [
            {
              "args" = [
                "--config.file=/etc/blackbox_exporter/config.yml",
                "--web.listen-address=:19115",
              ]
              "image" = "quay.io/prometheus/blackbox-exporter:v0.21.0"
              "name" = "blackbox-exporter"
              "ports" = [
                {
                  "containerPort" = 19115
                  "name" = "http"
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
                "runAsNonRoot" = true
                "runAsUser" = 65534
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/blackbox_exporter/"
                  "name" = "config"
                  "readOnly" = true
                },
              ]
            },
            {
              "args" = [
                "--webhook-url=http://localhost:19115/-/reload",
                "--volume-dir=/etc/blackbox_exporter/",
              ]
              "image" = "jimmidyson/configmap-reload:v0.5.0"
              "name" = "module-configmap-reloader"
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
                "runAsNonRoot" = true
                "runAsUser" = 65534
              }
              "terminationMessagePath" = "/dev/termination-log"
              "terminationMessagePolicy" = "FallbackToLogsOnError"
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/blackbox_exporter/"
                  "name" = "config"
                  "readOnly" = true
                },
              ]
            },
            {
              "args" = [
                "--logtostderr",
                "--secure-listen-address=:9115",
                "--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
                "--upstream=http://127.0.0.1:19115/",
              ]
              "image" = "quay.io/brancz/kube-rbac-proxy:v0.12.0"
              "name" = "kube-rbac-proxy"
              "ports" = [
                {
                  "containerPort" = 9115
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
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "serviceAccountName" = "blackbox-exporter"
          "volumes" = [
            {
              "configMap" = {
                "name" = "blackbox-exporter-configuration"
              }
              "name" = "config"
            },
          ]
        }
      }
    }
  }
  depends_on = [module.setup]
}
