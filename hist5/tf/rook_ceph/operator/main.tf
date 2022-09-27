# From https://github.com/rook/rook/blob/v1.10.1/deploy/examples/operator.yaml

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
  }
}

variable "namespace" {
  type = string
}

resource "kubernetes_manifest" "configmap_rook_ceph_rook_ceph_operator_config" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "CSI_CEPHFS_FSGROUPPOLICY" = "File"
      "CSI_ENABLE_CEPHFS_SNAPSHOTTER" = "true"
      "CSI_ENABLE_CSIADDONS" = "false"
      "CSI_ENABLE_ENCRYPTION" = "false"
      "CSI_ENABLE_LIVENESS" = "false"
      "CSI_ENABLE_NFS_SNAPSHOTTER" = "true"
      "CSI_ENABLE_RBD_SNAPSHOTTER" = "true"
      "CSI_FORCE_CEPHFS_KERNEL_CLIENT" = "true"
      "CSI_GRPC_TIMEOUT_SECONDS" = "150"
      "CSI_NFS_FSGROUPPOLICY" = "File"
      "CSI_PLUGIN_ENABLE_SELINUX_HOST_MOUNT" = "false"
      "CSI_PLUGIN_PRIORITY_CLASSNAME" = "system-node-critical"
      "CSI_PROVISIONER_PRIORITY_CLASSNAME" = "system-cluster-critical"
      "CSI_PROVISIONER_REPLICAS" = "2"
      "CSI_RBD_FSGROUPPOLICY" = "File"
      "ROOK_CEPH_COMMANDS_TIMEOUT_SECONDS" = "15"
      "ROOK_CSI_ALLOW_UNSUPPORTED_VERSION" = "false"
      "ROOK_CSI_ENABLE_CEPHFS" = "true"
      "ROOK_CSI_ENABLE_GRPC_METRICS" = "false"
      "ROOK_CSI_ENABLE_NFS" = "false"
      "ROOK_CSI_ENABLE_RBD" = "true"
      "ROOK_ENABLE_DISCOVERY_DAEMON" = "false"
      "ROOK_LOG_LEVEL" = "INFO"
      "ROOK_OBC_WATCH_OPERATOR_NAMESPACE" = "true"
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "rook-ceph-operator-config"
      "namespace" = var.namespace
    }
  }
}

resource "kubernetes_manifest" "deployment_rook_ceph_rook_ceph_operator" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "rook-ceph-operator"
        "app.kubernetes.io/instance" = "rook-ceph"
        "app.kubernetes.io/name" = "rook-ceph"
        "app.kubernetes.io/part-of" = "rook-ceph-operator"
        "operator" = "rook"
        "storage-backend" = "ceph"
      }
      "name" = "rook-ceph-operator"
      "namespace" = var.namespace
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "rook-ceph-operator"
        }
      }
      "strategy" = {
        "type" = "Recreate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "rook-ceph-operator"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "ceph",
                "operator",
              ]
              "env" = [
                {
                  "name" = "ROOK_CURRENT_NAMESPACE_ONLY"
                  "value" = "false"
                },
                {
                  "name" = "ROOK_DISCOVER_DEVICES_INTERVAL"
                  "value" = "60m"
                },
                {
                  "name" = "ROOK_HOSTPATH_REQUIRES_PRIVILEGED"
                  "value" = "false"
                },
                {
                  "name" = "ROOK_ENABLE_SELINUX_RELABELING"
                  "value" = "true"
                },
                {
                  "name" = "ROOK_ENABLE_FSGROUP"
                  "value" = "true"
                },
                {
                  "name" = "ROOK_DISABLE_DEVICE_HOTPLUG"
                  "value" = "false"
                },
                {
                  "name" = "DISCOVER_DAEMON_UDEV_BLACKLIST"
                  "value" = "(?i)dm-[0-9]+,(?i)rbd[0-9]+,(?i)nbd[0-9]+"
                },
                {
                  "name" = "ROOK_UNREACHABLE_NODE_TOLERATION_SECONDS"
                  "value" = "5"
                },
                {
                  "name" = "ROOK_DISABLE_ADMISSION_CONTROLLER"
                  "value" = "false"
                },
                {
                  "name" = "NODE_NAME"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "spec.nodeName"
                    }
                  }
                },
                {
                  "name" = "POD_NAME"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.name"
                    }
                  }
                },
                {
                  "name" = "POD_NAMESPACE"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.namespace"
                    }
                  }
                },
              ]
              "image" = "rook/ceph:v1.10.1"
              "name" = "rook-ceph-operator"
              "ports" = [
                {
                  "containerPort" = 9443
                  "name" = "https-webhook"
                  "protocol" = "TCP"
                },
              ]
              "securityContext" = {
                "runAsGroup" = 2016
                "runAsNonRoot" = true
                "runAsUser" = 2016
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/rook"
                  "name" = "rook-config"
                },
                {
                  "mountPath" = "/etc/ceph"
                  "name" = "default-config-dir"
                },
                {
                  "mountPath" = "/etc/webhook"
                  "name" = "webhook-cert"
                },
              ]
            },
          ]
          "priorityClassName" = "system-cluster-critical"
          "serviceAccountName" = "rook-ceph-system"
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "rook-config"
            },
            {
              "emptyDir" = {}
              "name" = "default-config-dir"
            },
            {
              "emptyDir" = {}
              "name" = "webhook-cert"
            },
          ]
        }
      }
    }
  }
}
