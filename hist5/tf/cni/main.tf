# https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

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

variable "pod_network_cidr" {
  type = string
}

resource "kubernetes_cluster_role" "flannel" {
  metadata {
    name = "flannel"
  }
  rule {
    api_groups = [""]
    resources = ["pods"]
    verbs = ["get"]
  }
  rule {
    api_groups = [""]
    resources = ["nodes"]
    verbs = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources = ["nodes/status"]
    verbs = ["patch"]
  }
}

resource "kubernetes_cluster_role_binding" "flannel" {
  metadata {
    name = "flannel"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.flannel.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.flannel.metadata[0].name
    namespace = kubernetes_service_account.flannel.metadata[0].namespace
  }
}

resource "kubernetes_service_account" "flannel" {
  metadata {
    name      = "flannel"
    namespace = var.namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_config_map" "flannel" {
  metadata {
    labels = {
      "app"  = "flannel"
      "tier" = "node"
    }
    name      = "flannel"
    namespace = var.namespace
  }
  data = {
    "cni-conf.json" = jsonencode(
      {
        cniVersion = "0.3.1"
        name       = "cbr0"
        plugins = [
          {
            delegate = {
              hairpinMode      = true
              isDefaultGateway = true
            }
            type = "flannel"
          },
          {
            capabilities = {
              portMappings = true
            }
            type = "portmap"
          },
        ]
      }
    )
    "net-conf.json" = jsonencode(
      {
        Backend = {
          Type = "vxlan"
          Port = 4789
        }
        Network = var.pod_network_cidr
      }
    )
  }
}

resource "kubernetes_daemonset" "flannel" {
  metadata {
    labels = {
      "app"  = "flannel"
      "tier" = "node"
    }
    name      = "flannel"
    namespace = var.namespace
  }
  spec {
    min_ready_seconds      = 0
    revision_history_limit = 10
    selector {
      match_labels = { "app" = "flannel" }
    }
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "1"
      }
    }
    template {
      metadata {
        labels = {
          "app"  = "flannel"
          "tier" = "node"
        }
      }
      spec {
        automount_service_account_token  = true
        dns_policy                       = "ClusterFirst"
        enable_service_links             = false
        host_ipc                         = false
        host_network                     = true
        host_pid                         = false
        node_selector                    = {}
        priority_class_name              = "system-node-critical"
        restart_policy                   = "Always"
        service_account_name             = "flannel"
        share_process_namespace          = false
        termination_grace_period_seconds = 30
        init_container {
          args                       = ["-f", "/etc/kube-flannel/cni-conf.json", "/etc/cni/net.d/10-flannel.conflist"]
          command                    = ["cp"]
          image                      = "ghcr.io/siderolabs/flannel:v0.19.2"
          image_pull_policy          = "IfNotPresent"
          name                       = "install-config"
          stdin                      = false
          stdin_once                 = false
          termination_message_path   = "/dev/termination-log"
          termination_message_policy = "File"
          tty                        = false
          volume_mount {
            mount_path = "/etc/cni/net.d"
            name       = "cni"
            read_only  = false
          }
          volume_mount {
            mount_path = "/etc/kube-flannel/"
            name       = "flannel-cfg"
            read_only  = false
          }
        }
        init_container {
          command                    = ["/install-cni.sh"]
          image                      = "ghcr.io/siderolabs/install-cni:v1.2.0-1-g116c5a9"
          image_pull_policy          = "IfNotPresent"
          name                       = "install-cni"
          stdin                      = false
          stdin_once                 = false
          termination_message_path   = "/dev/termination-log"
          termination_message_policy = "File"
          tty                        = false
          volume_mount {
            mount_path = "/host/opt/cni/bin"
            name       = "cni-plugin"
            read_only  = false
          }
        }
        container {
          args                       = ["--ip-masq", "--kube-subnet-mgr", "-iface", "wg-hist5"]
          command                    = ["/opt/bin/flanneld"]
          image                      = "ghcr.io/siderolabs/flannel:v0.19.2"
          image_pull_policy          = "IfNotPresent"
          name                       = "kube-flannel"
          stdin                      = false
          stdin_once                 = false
          termination_message_path   = "/dev/termination-log"
          termination_message_policy = "File"
          tty                        = false
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.namespace"
              }
            }
          }
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "status.podIP"
              }
            }
          }
          env {
            name  = "EVENT_QUEUE_DEPTH"
            value = "5000"
          }
          resources {
            limits = {
              "cpu"    = "100m"
              "memory" = "50Mi"
            }
            requests = {
              "cpu"    = "100m"
              "memory" = "50Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false
            run_as_non_root            = false
            capabilities {
              add = [
                "NET_ADMIN",
                "NET_RAW",
              ]
              drop = []
            }
          }
          volume_mount {
            mount_path = "/run/flannel"
            name       = "run"
            read_only  = false
          }
          volume_mount {
            mount_path = "/etc/kube-flannel/"
            name       = "flannel-cfg"
            read_only  = false
          }
          volume_mount {
            mount_path = "/run/xtables.lock"
            name       = "xtables-lock"
            read_only  = false
          }
        }
        volume {
          name = "run"
          host_path {
            path = "/run/flannel"
          }
        }
        volume {
          name = "cni-plugin"
          host_path {
            path = "/opt/cni/bin"
          }
        }
        volume {
          name = "cni"
          host_path {
            path = "/etc/cni/net.d"
          }
        }
        volume {
          name = "flannel-cfg"
          config_map {
            default_mode = "0644"
            name         = "flannel"
            optional     = false
          }
        }
        volume {
          name = "xtables-lock"
          host_path {
            path = "/run/xtables.lock"
            type = "FileOrCreate"
          }
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/os"
                  operator = "In"
                  values = ["linux"]
                }
              }
            }
          }
        }
        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }
      }
    }
  }
}

