# From https://github.com/rook/rook/blob/v1.10.1/deploy/examples/monitoring/rbac.yaml

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_monitor" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rook-ceph-monitor"
      "namespace" = "rook-ceph"
    }
    "rules" = [
      {
        "apiGroups" = [
          "monitoring.coreos.com",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_rook_ceph_rook_ceph_monitor" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "name" = "rook-ceph-monitor"
      "namespace" = "rook-ceph"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "rook-ceph-monitor"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-ceph-system"
        "namespace" = "rook-ceph"
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_metrics" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rook-ceph-metrics"
      "namespace" = "rook-ceph"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "services",
          "endpoints",
          "pods",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_rook_ceph_rook_ceph_metrics" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "name" = "rook-ceph-metrics"
      "namespace" = "rook-ceph"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "rook-ceph-metrics"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-k8s"
        "namespace" = "monitoring"
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_monitor_mgr" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rook-ceph-monitor-mgr"
      "namespace" = "rook-ceph"
    }
    "rules" = [
      {
        "apiGroups" = [
          "monitoring.coreos.com",
        ]
        "resources" = [
          "servicemonitors",
        ]
        "verbs" = [
          "get",
          "list",
          "create",
          "update",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_rook_ceph_rook_ceph_monitor_mgr" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "name" = "rook-ceph-monitor-mgr"
      "namespace" = "rook-ceph"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "rook-ceph-monitor-mgr"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-ceph-mgr"
        "namespace" = "rook-ceph"
      },
    ]
  }
}
