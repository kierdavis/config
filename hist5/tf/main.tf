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

module "rook_ceph" {
  source = "./rook_ceph"
}

module "shells" {
  source = "./shells"
  namespace = "default"
}
