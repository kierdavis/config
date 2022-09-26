# From https://github.com/prometheus-operator/kube-prometheus/blob/v0.11.0/manifests/./prometheus-roleBindingSpecificNamespaces.yaml

resource "kubernetes_manifest" "rolebinding_prometheus_k8s" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "namespace" = "default"
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "prometheus-k8s"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "prometheus-k8s"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-k8s"
        "namespace" = "monitoring"
      },
    ]
  }
  depends_on = [module.setup]
}

resource "kubernetes_manifest" "rolebinding_kube_system_prometheus_k8s" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "prometheus-k8s"
      "namespace" = "kube-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "prometheus-k8s"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-k8s"
        "namespace" = "monitoring"
      },
    ]
  }
  depends_on = [module.setup]
}

resource "kubernetes_manifest" "rolebinding_monitoring_prometheus_k8s" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "prometheus"
        "app.kubernetes.io/instance" = "k8s"
        "app.kubernetes.io/name" = "prometheus"
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "app.kubernetes.io/version" = "2.36.1"
      }
      "name" = "prometheus-k8s"
      "namespace" = "monitoring"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "prometheus-k8s"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-k8s"
        "namespace" = "monitoring"
      },
    ]
  }
  depends_on = [module.setup]
}
