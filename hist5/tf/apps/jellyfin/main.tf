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

variable "storage_classes" {
  type = map(any)
}

variable "torrent_downloads_pvc" {
  type = string
}

variable "media_pvc" {
  type = string
}

resource "kubernetes_persistent_volume_claim" "stateful_config" {
  metadata {
    name = "jellyfin-stateful-config"
    namespace = var.namespace
    labels = {
      app = "jellyfin"
    }
  }
  spec {
    storage_class_name = var.storage_classes.ceph_blk_replicated_0
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "main" {
  metadata {
    name = "jellyfin"
    namespace = var.namespace
    labels = {
      app = "jellyfin"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "jellyfin"
      }
    }
    strategy {
      type = "Recreate"  # Because only one pod can use the PVC at a time.
    }
    template {
      metadata {
        labels = {
          app = "jellyfin"
        }
      }
      spec {
        container {
          name = "jellyfin"
          image = "linuxserver/jellyfin"
          env {
            name = "TZ"
            value = "Europe/London"
          }
          port {
            name = "ui"
            container_port = 8096
          }
          volume_mount {
            name = "config"
            mount_path = "/config"
          }
          volume_mount {
            name = "media"
            mount_path = "/data"
          }
          volume_mount {
            name = "torrent-downloads"
            mount_path = "/net/hist5/torrent-downloads"
            read_only = true
          }
          resources {
            requests = {
              cpu = "1"
              memory = "1.5Gi"
            }
            limits = {
              cpu = "1"
              memory = "2Gi"
            }
          }
        }
        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.stateful_config.metadata[0].name
          }
        }
        volume {
          name = "media"
          persistent_volume_claim {
            claim_name = var.media_pvc
          }
        }
        volume {
          name = "torrent-downloads"
          persistent_volume_claim {
            claim_name = var.torrent_downloads_pvc
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "main" {
  metadata {
    name = "jellyfin"
    namespace = var.namespace
    labels = {
      app = "jellyfin"
    }
  }
  spec {
    selector = {
      app = "jellyfin"
    }
    port {
      name = "ui"
      port = 80
      target_port = "ui"
      app_protocol = "http"
    }
  }
}
