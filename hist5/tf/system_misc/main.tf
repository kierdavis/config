terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
  }
}

resource "kubernetes_priority_class" "default" {
  metadata {
    name = "default"
  }
  value = 1000
  global_default = true
}

resource "kubernetes_priority_class" "observability_critical" {
  metadata {
    name = "observability-critical"
  }
  value = 2000
}
