terraform {
  required_providers {
    ceph = {
      source = "cernops/ceph"
      version = "~> 0.1.4"
    }
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

data "kubernetes_secret" "ceph_config" {
  metadata {
    name = "rook-ceph-config"
    namespace = "rook-ceph"
  }
}

data "kubernetes_secret" "ceph_admin_keyring" {
  metadata {
    name = "rook-ceph-admin-keyring"
    namespace = "rook-ceph"
  }
}

provider "ceph" {
  keyring = data.kubernetes_secret.ceph_admin_keyring.data.keyring
  mon_host = data.kubernetes_secret.ceph_config.data.mon_host
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

module "apps" {
  source = "./apps"
  storage_classes = module.rook_ceph.storage_classes
  shared_filesystem_uid = local.cue.sharedFilesystemUid
}

module "cloudflare" {
  source = "./cloudflare"
  cue = local.cue
}

module "cni" {
  source = "./cni"
  pod_network_cidr = local.cue.networks.pods.cidr
  pod_network_mtu = local.cue.networks.pods.mtu
}

module "gcp" {
  source = "./gcp"
  cue = local.cue
}

module "prometheus" {
  source = "./prometheus"
  storage_classes = module.rook_ceph.storage_classes
}

module "rook_ceph" {
  source = "./rook_ceph"
}

module "shells" {
  source = "./shells"
  namespace = "default"
}

module "system_misc" {
  source = "./system_misc"
}
