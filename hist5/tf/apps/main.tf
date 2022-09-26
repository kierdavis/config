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

variable "shared_filesystem_uid" {
  type = number
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = "kier-apps"
  }
}

locals {
  namespace = kubernetes_namespace.main.metadata[0].name
}

resource "kubernetes_persistent_volume_claim" "torrent_downloads" {
  metadata {
    name = "torrent-downloads"
    namespace = local.namespace
  }
  spec {
    storage_class_name = var.storage_classes.ceph_fs_replicated_0
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "400Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "media" {
  metadata {
    name = "media"
    namespace = local.namespace
  }
  spec {
    storage_class_name = var.storage_classes.ceph_fs_replicated_0
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
  }
}

module "transmission" {
  source = "./transmission"
  namespace = local.namespace
  storage_classes = var.storage_classes
  shared_filesystem_uid = var.shared_filesystem_uid
  torrent_downloads_pvc = kubernetes_persistent_volume_claim.torrent_downloads.metadata[0].name
}
