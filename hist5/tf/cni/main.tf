# From https://cloud.weave.works/k8s/v1.16/net.yaml

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
  }
}

variable "pod_network_cidr" {
  type = string
}

variable "pod_network_mtu" {
  type = number
}

resource "kubernetes_service_account" "main" {
  metadata {
    name = "weave-net"
    namespace = "kube-system"
    labels = {
      "name" = "weave-net"
    }
    annotations = {
      "cloud.weave.works/launcher-info" = <<-EOT
      {
        "original-request": {
          "url": "/k8s/v1.16/net.yaml?k8s-version=Q2xpZW50IFZlcnNpb246IHZlcnNpb24uSW5mb3tNYWpvcjoiMSIsIE1pbm9yOiIyMyIsIEdpdFZlcnNpb246InYxLjIzLjUiLCBHaXRDb21taXQ6ImMyODVlNzgxMzMxYTM3ODVhN2Y0MzYwNDJjNjVjNTY0MWNlOGE5ZTkiLCBHaXRUcmVlU3RhdGU6ImFyY2hpdmUiLCBCdWlsZERhdGU6IjE5ODAtMDEtMDFUMDA6MDA6MDBaIiwgR29WZXJzaW9uOiJnbzEuMTcuMTAiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQpTZXJ2ZXIgVmVyc2lvbjogdmVyc2lvbi5JbmZve01ham9yOiIxIiwgTWlub3I6IjI1IiwgR2l0VmVyc2lvbjoidjEuMjUuMCIsIEdpdENvbW1pdDoiYTg2NmNiZTJlNWJiYWEwMWNmZDVlOTY5YWEzZTAzM2YzMjgyYThhMiIsIEdpdFRyZWVTdGF0ZToiY2xlYW4iLCBCdWlsZERhdGU6IjIwMjItMDgtMjNUMTc6Mzg6MTVaIiwgR29WZXJzaW9uOiJnbzEuMTkiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQo=",
          "date": "Sat Sep 24 2022 21:36:54 GMT+0000 (UTC)"
        },
        "email-address": "support@weave.works"
      }
      EOT
    }
  }
}

resource "kubernetes_cluster_role" "main" {
  metadata {
    name = "weave-net"
    labels = {
      "name" = "weave-net"
    }
    annotations = {
      "cloud.weave.works/launcher-info" = <<-EOT
      {
        "original-request": {
          "url": "/k8s/v1.16/net.yaml?k8s-version=Q2xpZW50IFZlcnNpb246IHZlcnNpb24uSW5mb3tNYWpvcjoiMSIsIE1pbm9yOiIyMyIsIEdpdFZlcnNpb246InYxLjIzLjUiLCBHaXRDb21taXQ6ImMyODVlNzgxMzMxYTM3ODVhN2Y0MzYwNDJjNjVjNTY0MWNlOGE5ZTkiLCBHaXRUcmVlU3RhdGU6ImFyY2hpdmUiLCBCdWlsZERhdGU6IjE5ODAtMDEtMDFUMDA6MDA6MDBaIiwgR29WZXJzaW9uOiJnbzEuMTcuMTAiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQpTZXJ2ZXIgVmVyc2lvbjogdmVyc2lvbi5JbmZve01ham9yOiIxIiwgTWlub3I6IjI1IiwgR2l0VmVyc2lvbjoidjEuMjUuMCIsIEdpdENvbW1pdDoiYTg2NmNiZTJlNWJiYWEwMWNmZDVlOTY5YWEzZTAzM2YzMjgyYThhMiIsIEdpdFRyZWVTdGF0ZToiY2xlYW4iLCBCdWlsZERhdGU6IjIwMjItMDgtMjNUMTc6Mzg6MTVaIiwgR29WZXJzaW9uOiJnbzEuMTkiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQo=",
          "date": "Sat Sep 24 2022 21:36:54 GMT+0000 (UTC)"
        },
        "email-address": "support@weave.works"
      }
      EOT
    }
  }
  rule {
    api_groups = [""]
    resources = ["pods", "namespaces", "nodes"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources = ["networkpolicies"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources = ["nodes/status"]
    verbs = ["patch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "main" {
  metadata {
    name = "weave-net"
    labels = {
      "name" = "weave-net"
    }
    annotations = {
      "cloud.weave.works/launcher-info" = <<-EOT
      {
        "original-request": {
          "url": "/k8s/v1.16/net.yaml?k8s-version=Q2xpZW50IFZlcnNpb246IHZlcnNpb24uSW5mb3tNYWpvcjoiMSIsIE1pbm9yOiIyMyIsIEdpdFZlcnNpb246InYxLjIzLjUiLCBHaXRDb21taXQ6ImMyODVlNzgxMzMxYTM3ODVhN2Y0MzYwNDJjNjVjNTY0MWNlOGE5ZTkiLCBHaXRUcmVlU3RhdGU6ImFyY2hpdmUiLCBCdWlsZERhdGU6IjE5ODAtMDEtMDFUMDA6MDA6MDBaIiwgR29WZXJzaW9uOiJnbzEuMTcuMTAiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQpTZXJ2ZXIgVmVyc2lvbjogdmVyc2lvbi5JbmZve01ham9yOiIxIiwgTWlub3I6IjI1IiwgR2l0VmVyc2lvbjoidjEuMjUuMCIsIEdpdENvbW1pdDoiYTg2NmNiZTJlNWJiYWEwMWNmZDVlOTY5YWEzZTAzM2YzMjgyYThhMiIsIEdpdFRyZWVTdGF0ZToiY2xlYW4iLCBCdWlsZERhdGU6IjIwMjItMDgtMjNUMTc6Mzg6MTVaIiwgR29WZXJzaW9uOiJnbzEuMTkiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQo=",
          "date": "Sat Sep 24 2022 21:36:54 GMT+0000 (UTC)"
        },
        "email-address": "support@weave.works"
      }
      EOT
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = kubernetes_cluster_role.main.metadata[0].name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.main.metadata[0].name
    namespace = kubernetes_service_account.main.metadata[0].namespace
  }
}

resource "kubernetes_role" "main" {
  metadata {
    name = "weave-net"
    namespace = "kube-system"
    labels = {
      "name" = "weave-net"
    }
    annotations = {
      "cloud.weave.works/launcher-info" = <<-EOT
      {
        "original-request": {
          "url": "/k8s/v1.16/net.yaml?k8s-version=Q2xpZW50IFZlcnNpb246IHZlcnNpb24uSW5mb3tNYWpvcjoiMSIsIE1pbm9yOiIyMyIsIEdpdFZlcnNpb246InYxLjIzLjUiLCBHaXRDb21taXQ6ImMyODVlNzgxMzMxYTM3ODVhN2Y0MzYwNDJjNjVjNTY0MWNlOGE5ZTkiLCBHaXRUcmVlU3RhdGU6ImFyY2hpdmUiLCBCdWlsZERhdGU6IjE5ODAtMDEtMDFUMDA6MDA6MDBaIiwgR29WZXJzaW9uOiJnbzEuMTcuMTAiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQpTZXJ2ZXIgVmVyc2lvbjogdmVyc2lvbi5JbmZve01ham9yOiIxIiwgTWlub3I6IjI1IiwgR2l0VmVyc2lvbjoidjEuMjUuMCIsIEdpdENvbW1pdDoiYTg2NmNiZTJlNWJiYWEwMWNmZDVlOTY5YWEzZTAzM2YzMjgyYThhMiIsIEdpdFRyZWVTdGF0ZToiY2xlYW4iLCBCdWlsZERhdGU6IjIwMjItMDgtMjNUMTc6Mzg6MTVaIiwgR29WZXJzaW9uOiJnbzEuMTkiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQo=",
          "date": "Sat Sep 24 2022 21:36:54 GMT+0000 (UTC)"
        },
        "email-address": "support@weave.works"
      }
      EOT
    }
  }
  rule {
    api_groups = [""]
    resource_names = ["weave-net"]
    resources = ["configmaps"]
    verbs = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    verbs = ["create"]
  }
}

resource "kubernetes_role_binding" "main" {
  metadata {
    name = "weave-net"
    namespace = "kube-system"
    labels = {
      "name" = "weave-net"
    }
    annotations = {
      "cloud.weave.works/launcher-info" = <<-EOT
      {
        "original-request": {
          "url": "/k8s/v1.16/net.yaml?k8s-version=Q2xpZW50IFZlcnNpb246IHZlcnNpb24uSW5mb3tNYWpvcjoiMSIsIE1pbm9yOiIyMyIsIEdpdFZlcnNpb246InYxLjIzLjUiLCBHaXRDb21taXQ6ImMyODVlNzgxMzMxYTM3ODVhN2Y0MzYwNDJjNjVjNTY0MWNlOGE5ZTkiLCBHaXRUcmVlU3RhdGU6ImFyY2hpdmUiLCBCdWlsZERhdGU6IjE5ODAtMDEtMDFUMDA6MDA6MDBaIiwgR29WZXJzaW9uOiJnbzEuMTcuMTAiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQpTZXJ2ZXIgVmVyc2lvbjogdmVyc2lvbi5JbmZve01ham9yOiIxIiwgTWlub3I6IjI1IiwgR2l0VmVyc2lvbjoidjEuMjUuMCIsIEdpdENvbW1pdDoiYTg2NmNiZTJlNWJiYWEwMWNmZDVlOTY5YWEzZTAzM2YzMjgyYThhMiIsIEdpdFRyZWVTdGF0ZToiY2xlYW4iLCBCdWlsZERhdGU6IjIwMjItMDgtMjNUMTc6Mzg6MTVaIiwgR29WZXJzaW9uOiJnbzEuMTkiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQo=",
          "date": "Sat Sep 24 2022 21:36:54 GMT+0000 (UTC)"
        },
        "email-address": "support@weave.works"
      }
      EOT
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = kubernetes_role.main.metadata[0].name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.main.metadata[0].name
    namespace = kubernetes_service_account.main.metadata[0].namespace
  }
}

resource "kubernetes_daemonset" "main" {
  metadata {
    name = "weave-net"
    namespace = "kube-system"
    labels = {
      "name" = "weave-net"
    }
    annotations = {
      "cloud.weave.works/launcher-info" = <<-EOT
      {
        "original-request": {
          "url": "/k8s/v1.16/net.yaml?k8s-version=Q2xpZW50IFZlcnNpb246IHZlcnNpb24uSW5mb3tNYWpvcjoiMSIsIE1pbm9yOiIyMyIsIEdpdFZlcnNpb246InYxLjIzLjUiLCBHaXRDb21taXQ6ImMyODVlNzgxMzMxYTM3ODVhN2Y0MzYwNDJjNjVjNTY0MWNlOGE5ZTkiLCBHaXRUcmVlU3RhdGU6ImFyY2hpdmUiLCBCdWlsZERhdGU6IjE5ODAtMDEtMDFUMDA6MDA6MDBaIiwgR29WZXJzaW9uOiJnbzEuMTcuMTAiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQpTZXJ2ZXIgVmVyc2lvbjogdmVyc2lvbi5JbmZve01ham9yOiIxIiwgTWlub3I6IjI1IiwgR2l0VmVyc2lvbjoidjEuMjUuMCIsIEdpdENvbW1pdDoiYTg2NmNiZTJlNWJiYWEwMWNmZDVlOTY5YWEzZTAzM2YzMjgyYThhMiIsIEdpdFRyZWVTdGF0ZToiY2xlYW4iLCBCdWlsZERhdGU6IjIwMjItMDgtMjNUMTc6Mzg6MTVaIiwgR29WZXJzaW9uOiJnbzEuMTkiLCBDb21waWxlcjoiZ2MiLCBQbGF0Zm9ybToibGludXgvYW1kNjQifQo=",
          "date": "Sat Sep 24 2022 21:36:54 GMT+0000 (UTC)"
        },
        "email-address": "support@weave.works"
      }
      EOT
    }
  }
  spec {
    min_ready_seconds = 5
    selector {
      match_labels = {
        "name" = "weave-net"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          "name" = "weave-net"
        }
      }
      spec {
        dns_policy = "ClusterFirstWithHostNet"
        host_network = true
        priority_class_name = "system-node-critical"
        restart_policy = "Always"
        service_account_name = kubernetes_service_account.main.metadata[0].name
        # Workaround for missing 'loopback' plugin.
        init_container {
          name = "setup-standard-cni-plugins"
          image = "docker.io/kierdavis/cni-plugin-installer:v1.1.1-2"
          volume_mount {
            name = "cni-bin"
            mount_path = "/host/opt/cni/bin"
          }
        }
        init_container {
          name = "weave-init"
          image = "ghcr.io/weaveworks/launcher/weave-kube:2.8.1"
          command = ["/home/weave/init.sh"]
          security_context {
            privileged = true
          }
          volume_mount {
            name = "cni-bin"
            mount_path = "/host/opt/cni/bin"
          }
          # volume_mount {
          #   name = "cni-bin2"
          #   mount_path = "/host/home"
          # }
          volume_mount {
            name = "cni-conf"
            mount_path = "/host/etc"
          }
          volume_mount {
            name = "lib-modules"
            mount_path = "/lib/modules"
          }
          volume_mount {
            name = "xtables-lock"
            mount_path = "/run/xtables.lock"
          }
        }
        container {
          name = "weave"
          image = "ghcr.io/weaveworks/launcher/weave-kube:2.8.1"
          command = ["/home/weave/launch.sh"]
          env {
            name = "HOSTNAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name = "IPALLOC_RANGE"
            value = var.pod_network_cidr
          }
          env {
            name = "WEAVE_MTU"
            value = tostring(var.pod_network_mtu)
          }
          env {
            name = "INIT_CONTAINER"
            value = "true"
          }
          readiness_probe {
            http_get {
              host = "127.0.0.1"
              path = "/status"
              port = 6784
            }
          }
          resources {
            requests = {
              cpu = "50m"
              memory = "100Mi"
            }
          }
          security_context {
            privileged = true
          }
          volume_mount {
            name = "weavedb"
            mount_path = "/weavedb"
          }
          volume_mount {
            name = "dbus"
            mount_path = "/host/var/lib/dbus"
          }
          volume_mount {
            name = "machine-id"
            mount_path = "/host/etc/machine-id"
            read_only = true
          }
          volume_mount {
            name = "xtables-lock"
            mount_path = "/run/xtables.lock"
          }
        }
        container {
          name = "weave-npc"
          image = "ghcr.io/weaveworks/launcher/weave-npc:2.8.1"
          env {
            name = "HOSTNAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path = "spec.nodeName"
              }
            }
          }
          resources {
            requests = {
              cpu = "50m"
              memory = "100Mi"
            }
          }
          security_context {
            privileged = true
          }
          volume_mount {
            name = "xtables-lock"
            mount_path = "/run/xtables.lock"
          }
        }
        toleration {
          effect = "NoSchedule"
          operator = "Exists"
        }
        toleration {
          effect = "NoExecute"
          operator = "Exists"
        }
        volume {
          name = "weavedb"
          host_path {
            path = "/var/lib/weave"
          }
        }
        volume {
          name = "cni-bin"
          host_path {
            path = "/opt/cni/bin"
          }
        }
        #volume {
        #  name = "cni-bin2"
        #  host_path {
        #    path = "/home"
        #  }
        #}
        volume {
          name = "cni-conf"
          host_path {
            path = "/etc"
          }
        }
        volume {
          name = "dbus"
          host_path {
            path = "/var/lib/dbus"
          }
        }
        volume {
          name = "lib-modules"
          host_path {
            path = "/lib/modules"
          }
        }
        volume {
          name = "machine-id"
          host_path {
            path = "/etc/machine-id"
            type = "FileOrCreate"
          }
        }
        volume {
          name = "xtables-lock"
          host_path {
            path = "/run/xtables.lock"
            type = "FileOrCreate"
          }
        }
      }
    }
  }
}
