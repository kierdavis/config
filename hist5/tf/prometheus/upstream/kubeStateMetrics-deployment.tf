# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/kubeStateMetrics-deployment.yaml

resource "kubernetes_manifest" "deployment_monitoring_kube_state_metrics" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "exporter"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.5.0"
      }
      "name" = "kube-state-metrics"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "exporter"
          "app.kubernetes.io/name" = "kube-state-metrics"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "kubectl.kubernetes.io/default-container" = "kube-state-metrics"
          }
          "labels" = {
            "app.kubernetes.io/component" = "exporter"
            "app.kubernetes.io/name" = "kube-state-metrics"
            "app.kubernetes.io/part-of" = "kube-prometheus"
            "app.kubernetes.io/version" = "2.5.0"
          }
        }
        "spec" = {
          "automountServiceAccountToken" = true
          "containers" = [
            {
              "args" = [
                "--host=127.0.0.1",
                "--port=8081",
                "--telemetry-host=127.0.0.1",
                "--telemetry-port=8082",
              ]
              "image" = "k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.5.0"
              "name" = "kube-state-metrics"
              "resources" = {
                "limits" = {
                  "cpu" = "100m"
                  "memory" = "250Mi"
                }
                "requests" = {
                  "cpu" = "10m"
                  "memory" = "190Mi"
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
                "runAsUser" = 65534
              }
            },
            {
              "args" = [
                "--logtostderr",
                "--secure-listen-address=:8443",
                "--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
                "--upstream=http://127.0.0.1:8081/",
              ]
              "image" = "quay.io/brancz/kube-rbac-proxy:v0.12.0"
              "name" = "kube-rbac-proxy-main"
              "ports" = [
                {
                  "containerPort" = 8443
                  "name" = "https-main"
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "40m"
                  "memory" = "40Mi"
                }
                "requests" = {
                  "cpu" = "20m"
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
            {
              "args" = [
                "--logtostderr",
                "--secure-listen-address=:9443",
                "--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
                "--upstream=http://127.0.0.1:8082/",
              ]
              "image" = "quay.io/brancz/kube-rbac-proxy:v0.12.0"
              "name" = "kube-rbac-proxy-self"
              "ports" = [
                {
                  "containerPort" = 9443
                  "name" = "https-self"
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
          "serviceAccountName" = "kube-state-metrics"
        }
      }
    }
  }
  depends_on = [module.setup]
}
