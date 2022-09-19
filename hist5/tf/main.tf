terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.23.0"
    }
    cue = {
      source = "xinau/cue"
      version = "~> 0.1.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
  }
}

data "cue_export" "main" {
  working_dir = "../cue"
}

locals {
  cue = jsondecode(data.cue_export.main.rendered)
}

provider "cloudflare" {
  api_token = local.cue.cloudflare.apiToken
}

provider "kubernetes" {
  host = local.cue.kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.cue.kubeconfig.clusters[0].cluster["certificate-authority-data"])
  client_certificate = base64decode(local.cue.kubeconfig.users[0].user["client-certificate-data"])
  client_key = base64decode(local.cue.kubeconfig.users[0].user["client-key-data"])
}

resource "kubernetes_namespace" "system" {
  metadata {
    name = "system"
  }
}

module "apps" {
  source = "./apps"
  storage_classes = module.rook_ceph.storage_classes
}

module "cloudflare" {
  source = "./cloudflare"
  cue = local.cue
}

module "cni" {
  source = "./cni"
  namespace = kubernetes_namespace.system.metadata[0].name
  pod_network_cidr = local.cue.networks.pods.cidr
}

module "gcp" {
  source = "./gcp"
  cue = local.cue
}

module "rook_ceph" {
  source = "./rook_ceph"
}

module "shells" {
  source = "./shells"
  namespace = kubernetes_namespace.system.metadata[0].name
}

module "theila" {
  source = "./theila"
  namespace = kubernetes_namespace.system.metadata[0].name
}
