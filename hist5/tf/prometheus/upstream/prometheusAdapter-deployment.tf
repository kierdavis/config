# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/prometheusAdapter-deployment.yaml

resource "kubernetes_manifest" "deployment_monitoring_prometheus_adapter" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "metrics-adapter"
        "app.kubernetes.io/name" = "prometheus-adapter"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.9.1"
      }
      "name" = "prometheus-adapter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 2
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "metrics-adapter"
          "app.kubernetes.io/name" = "prometheus-adapter"
          "app.kubernetes.io/part-of" = "kube-prometheus"
        }
      }
      "strategy" = {
        "rollingUpdate" = {
          "maxSurge" = 1
          "maxUnavailable" = 1
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app.kubernetes.io/component" = "metrics-adapter"
            "app.kubernetes.io/name" = "prometheus-adapter"
            "app.kubernetes.io/part-of" = "kube-prometheus"
            "app.kubernetes.io/version" = "0.9.1"
          }
        }
        "spec" = {
          "automountServiceAccountToken" = true
          "containers" = [
            {
              "args" = [
                "--cert-dir=/var/run/serving-cert",
                "--config=/etc/adapter/config.yaml",
                "--logtostderr=true",
                "--metrics-relist-interval=1m",
                "--prometheus-url=http://prometheus-k8s.monitoring.svc:9090/",
                "--secure-port=6443",
                "--tls-cipher-suites=TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA",
              ]
              "image" = "k8s.gcr.io/prometheus-adapter/prometheus-adapter:v0.9.1"
              "livenessProbe" = {
                "failureThreshold" = 5
                "httpGet" = {
                  "path" = "/livez"
                  "port" = "https"
                  "scheme" = "HTTPS"
                }
                "initialDelaySeconds" = 30
                "periodSeconds" = 5
              }
              "name" = "prometheus-adapter"
              "ports" = [
                {
                  "containerPort" = 6443
                  "name" = "https"
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 5
                "httpGet" = {
                  "path" = "/readyz"
                  "port" = "https"
                  "scheme" = "HTTPS"
                }
                "initialDelaySeconds" = 30
                "periodSeconds" = 5
              }
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
                  "drop" = [
                    "ALL",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmpfs"
                },
                {
                  "mountPath" = "/var/run/serving-cert"
                  "name" = "volume-serving-cert"
                },
                {
                  "mountPath" = "/etc/adapter"
                  "name" = "config"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "priorityClassName" = "observability-critical"
          "serviceAccountName" = "prometheus-adapter"
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "tmpfs"
            },
            {
              "emptyDir" = {}
              "name" = "volume-serving-cert"
            },
            {
              "configMap" = {
                "name" = "adapter-config"
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
