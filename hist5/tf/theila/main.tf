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

resource "kubernetes_deployment" "main" {
  metadata {
    name = "theila"
    namespace = var.namespace
    labels = {
      app = "theila"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "theila"
      }
    }
    template {
      metadata {
        labels = {
          app = "theila"
        }
      }
      spec {
        container {
          name = "theila"
          image = "ghcr.io/siderolabs/theila"
          args = ["--address", "0.0.0.0"]
          port {
            name = "http"
            protocol = "TCP"
            container_port = 8080
          }
          resources {
            requests = {
              cpu = "10m"
              memory = "50Mi"
              ephemeral-storage = "0Mi"
            }
            limits = {
              cpu = "100m"
              memory = "100Mi"
              ephemeral-storage = "50Mi"
            }
          }
          # readiness_probe {
          #   http_get {
          #     path = "/healthz"
          #     port = "http"
          #   }
          #   initial_delay_seconds = 5
          #   period_seconds = 10
          #   timeout_seconds = 5
          #   success_threshold = 1
          #   failure_threshold = 3
          # }
          # liveness_probe {
          #   http_get {
          #     path = "/healthz"
          #     port = "http"
          #   }
          #   initial_delay_seconds = 5
          #   period_seconds = 10
          #   timeout_seconds = 5
          #   success_threshold = 1
          #   failure_threshold = 3
          # }
        }
      }
    }
  }
}

resource "kubernetes_service" "main" {
  metadata {
    name = "theila"
    namespace = var.namespace
    labels = {
      app = "theila"
    }
  }
  spec {
    selector = { "app" = "theila" }
    port {
      name = "http"
      port = 80
      target_port = "http"
      protocol = "TCP"
    }
  }
}
