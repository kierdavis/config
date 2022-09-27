terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
  }
}

variable "storage_classes" {
  type = map(any)
}

# Based on https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheus-prometheus.yaml
resource "kubernetes_manifest" "prometheus" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "Prometheus"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "k8s"
      "namespace" = "monitoring"
    }
    "spec" = {
      "alerting" = {
        "alertmanagers" = [
          {
            "apiVersion" = "v2"
            "name" = "alertmanager-main"
            "namespace" = "monitoring"
            "port" = "web"
          },
        ]
      }
      "enableFeatures" = []
      "externalLabels" = {}
      "image" = "quay.io/prometheus/prometheus:v2.36.1"
      "nodeSelector" = {
        "kubernetes.io/os" = "linux"
      }
      "podMetadata" = {
        "labels" = {
          "app.kubernetes.io/component" = "prometheus"
          "app.kubernetes.io/instance" = "k8s"
          "app.kubernetes.io/name" = "prometheus"
          "app.kubernetes.io/part-of" = "kube-prometheus"
          "app.kubernetes.io/version" = "2.36.1"
        }
      }
      "podMonitorNamespaceSelector" = {}
      "podMonitorSelector" = {}
      "priorityClassName" = "observability-critical"
      "probeNamespaceSelector" = {}
      "probeSelector" = {}
      "replicas" = 1
      "resources" = {
        "requests" = {
          "memory" = "400Mi"
        }
      }
      "ruleNamespaceSelector" = {}
      "ruleSelector" = {}
      "securityContext" = {
        "fsGroup" = 2000
        "runAsNonRoot" = true
        "runAsUser" = 1000
      }
      "serviceAccountName" = "prometheus-k8s"
      "serviceMonitorNamespaceSelector" = {}
      "serviceMonitorSelector" = {}
      "storage" = {
        "volumeClaimTemplate" = {
          "spec" = {
            "storageClassName" = var.storage_classes.ceph_blk_replicated_0
            "accessModes" = ["ReadWriteOnce"]
            "resources" = {
              "requests" = {
                "storage" = "1Gi"
              }
            }
          }
        }
      }
      "version" = "2.36.1"
    }
  }
}

# Based on https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./alertmanager-alertmanager.yaml
resource "kubernetes_manifest" "alertmanager" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "Alertmanager"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "alert-router"
        "app.kubernetes.io/instance" = "main"
        "app.kubernetes.io/name" = "alertmanager"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "0.24.0"
      }
      "name" = "main"
      "namespace" = "monitoring"
    }
    "spec" = {
      "image" = "quay.io/prometheus/alertmanager:v0.24.0"
      "nodeSelector" = {
        "kubernetes.io/os" = "linux"
      }
      "podMetadata" = {
        "labels" = {
          "app.kubernetes.io/component" = "alert-router"
          "app.kubernetes.io/instance" = "main"
          "app.kubernetes.io/name" = "alertmanager"
          "app.kubernetes.io/part-of" = "kube-prometheus"
          "app.kubernetes.io/version" = "0.24.0"
        }
      }
      "priorityClassName" = "observability-critical"
      "replicas" = 0
      "resources" = {
        "limits" = {
          "cpu" = "100m"
          "memory" = "100Mi"
        }
        "requests" = {
          "cpu" = "4m"
          "memory" = "100Mi"
        }
      }
      "securityContext" = {
        "fsGroup" = 2000
        "runAsNonRoot" = true
        "runAsUser" = 1000
      }
      "serviceAccountName" = "alertmanager-main"
      "storage" = {
        "volumeClaimTemplate" = {
          "spec" = {
            "storageClassName" = var.storage_classes.ceph_blk_replicated_0
            "accessModes" = ["ReadWriteOnce"]
            "resources" = {
              "requests" = {
                "storage" = "10Mi"
              }
            }
          }
        }
      }
      "version" = "0.24.0"
    }
  }
}
