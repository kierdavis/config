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

resource "kubernetes_daemonset" "host" {
  metadata {
    name = "host-shell"
    namespace = var.namespace
    labels = {
      app = "host-shell"
    }
  }
  spec {
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "100%"
      }
    }
    selector {
      match_labels = {
        app = "host-shell"
      }
    }
    template {
      metadata {
        labels = {
          app = "host-shell"
        }
      }
      spec {
        host_pid = true
        host_network = true
        container {
          name = "shell"
          image = "nixos/nix"
          command = ["/bin/sh", "-c", "nix-env -i -A nixpkgs.curl -A nixpkgs.iproute2 -A nixpkgs.iptables-legacy -A nixpkgs.iputils -A nixpkgs.nettools && exec sleep infinity"]
          security_context {
            privileged = true
          }
          resources {
            requests = {
              cpu = "1m"
              memory = "10Mi"
              ephemeral-storage = "1Gi"
            }
            limits = {
              cpu = "1"
              memory = "500Mi"
              ephemeral-storage = "1Gi"
            }
          }
          volume_mount {
            name = "host"
            mount_path = "/host"
            read_only = true
          }
        }
        volume {
          name = "host"
          host_path {
            path = "/"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "cluster" {
  metadata {
    name = "cluster-shell"
    namespace = var.namespace
    labels = {
      app = "cluster-shell"
    }
  }
  spec {
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "100%"
      }
    }
    selector {
      match_labels = {
        app = "cluster-shell"
      }
    }
    template {
      metadata {
        labels = {
          app = "cluster-shell"
        }
      }
      spec {
        container {
          name = "shell"
          image = "nixos/nix"
          command = ["/bin/sh", "-c", "nix-env -i -A nixpkgs.curl -A nixpkgs.iproute2 -A nixpkgs.iptables-legacy -A nixpkgs.iputils -A nixpkgs.nettools && exec sleep infinity"]
          security_context {
            privileged = true
          }
          resources {
            requests = {
              cpu = "1m"
              memory = "10Mi"
              ephemeral-storage = "1Gi"
            }
            limits = {
              cpu = "1"
              memory = "500Mi"
              ephemeral-storage = "1Gi"
            }
          }
        }
      }
    }
  }
}
