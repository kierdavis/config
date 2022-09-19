terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
  }
}

variable "storage_classes" {
  type = object({
    ceph_obj_nonvolatile_0 = string
  })
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = "kier-apps"
  }
}

locals {
  namespace = kubernetes_namespace.main.metadata[0].name
}

resource "kubernetes_manifest" "objectbucketclaim_archive" {
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind" = "ObjectBucketClaim"
    "metadata" = {
      "name" = "archive"
      "namespace" = local.namespace
    }
    "spec" = {
      "storageClassName" = var.storage_classes.ceph_obj_nonvolatile_0
      "generateBucketName" = "archive"
    }
  }
}
