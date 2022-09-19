# tfk8s -f .../rook/deploy/examples/common.yaml -o rook_ceph_common.tf

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = "rook-ceph"
  }
}

locals {
  namespace = kubernetes_namespace.main.metadata[0].name
}

resource "kubernetes_cluster_role" "cephfs_csi_nodeplugin" {
  metadata {
    name = "cephfs-csi-nodeplugin"
  }
  rule {
    api_groups = [""]
    resources = ["nodes"]
    verbs = ["get"]
  }
}

resource "kubernetes_cluster_role" "cephfs_external_provisioner_runner" {
  metadata {
    name = "cephfs-external-provisioner-runner"
  }
  rule {
    api_groups = [""]
    resources = ["secrets"]
    verbs = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumes"]
    verbs = ["get", "list", "watch", "create", "delete", "patch"]
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumeclaims"]
    verbs = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["storageclasses"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources = ["events"]
    verbs = ["list", "watch", "create", "update", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["volumeattachments"]
    verbs = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["volumeattachments/status"]
    verbs = ["patch"]
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumeclaims/status"]
    verbs = ["patch"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources = ["volumesnapshots"]
    verbs = ["get", "list"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources = ["volumesnapshotclasses"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources = ["volumesnapshotcontents"]
    verbs = ["get", "list", "watch", "patch", "update"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources = ["volumesnapshotcontents/status"]
    verbs = ["update", "patch"]
  }
}

resource "kubernetes_cluster_role" "rbd_csi_nodeplugin" {
  metadata {
    name = "rbd-csi-nodeplugin"
    labels = {
      "app.kubernetes.io/part-of" = "rook-ceph-operator"
      "operator" = "rook"
      "storage-backend" = "ceph"
    }
  }
  rule {
    api_groups = [""]
    resources = ["secrets"]
    verbs = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumes"]
    verbs = ["get", "list"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["volumeattachments"]
    verbs = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    verbs = ["get"]
  }
  rule {
    api_groups = [""]
    resources = ["serviceaccounts"]
    verbs = ["get"]
  }
  rule {
    api_groups = [""]
    resources = ["serviceaccounts/token"]
    verbs = ["create"]
  }
}

resource "kubernetes_cluster_role" "rbd_external_provisioner_runner" {
  metadata {
    name = "rbd-external-provisioner-runner"
  }
  rule {
    api_groups = [""]
    resources = ["secrets"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumes"]
    verbs = ["get", "list", "watch", "create", "delete", "patch"]
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumeclaims"]
    verbs = ["get", "list", "watch", "update"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["storageclasses"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources = ["events"]
    verbs = ["list", "watch", "create", "update", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["volumeattachments"]
    verbs = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["volumeattachments/status"]
    verbs = ["patch"]
  }
  rule {
    api_groups = [""]
    resources = ["nodes"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources = ["csinodes"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources = ["persistentvolumeclaims/status"]
    verbs = ["patch"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources = ["volumesnapshots"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources = ["volumesnapshotclasses"]
    verbs = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources = ["volumesnapshotcontents"]
    verbs = ["get", "list", "watch", "patch", "update"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources = ["volumesnapshotcontents/status"]
    verbs = ["update", "patch"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    verbs = ["get"]
  }
  rule {
    api_groups = [""]
    resources = ["serviceaccounts"]
    verbs = ["get"]
  }
  rule {
    api_groups = [""]
    resources = ["serviceaccounts/token"]
    verbs = ["create"]
  }
}

resource "kubernetes_cluster_role" "rook_ceph_cluster_mgmt" {
  metadata {
    name = "rook-ceph-cluster-mgmt"
    labels = {
      "app.kubernetes.io/part-of" = "rook-ceph-operator"
      "operator" = "rook"
      "storage-backend" = "ceph"
    }
  }
  rule {
    api_groups = ["", "apps", "extensions"]
    resources = ["secrets", "pods", "pods/log", "services", "configmaps", "deployments", "daemonsets"]
    verbs = ["get", "list", "watch", "patch", "create", "update", "delete"]
  }
}

resource "kubernetes_manifest" "clusterrole_rook_ceph_global" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/part-of" = "rook-ceph-operator"
        "operator" = "rook"
        "storage-backend" = "ceph"
      }
      "name" = "rook-ceph-global"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "nodes",
          "nodes/proxy",
          "services",
          "secrets",
          "configmaps",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "events",
          "persistentvolumes",
          "persistentvolumeclaims",
          "endpoints",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "patch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "storage.k8s.io",
        ]
        "resources" = [
          "storageclasses",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "jobs",
          "cronjobs",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "ceph.rook.io",
        ]
        "resources" = [
          "cephclients",
          "cephclusters",
          "cephblockpools",
          "cephfilesystems",
          "cephnfses",
          "cephobjectstores",
          "cephobjectstoreusers",
          "cephobjectrealms",
          "cephobjectzonegroups",
          "cephobjectzones",
          "cephbuckettopics",
          "cephbucketnotifications",
          "cephrbdmirrors",
          "cephfilesystemmirrors",
          "cephfilesystemsubvolumegroups",
          "cephblockpoolradosnamespaces",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "ceph.rook.io",
        ]
        "resources" = [
          "cephclients/status",
          "cephclusters/status",
          "cephblockpools/status",
          "cephfilesystems/status",
          "cephnfses/status",
          "cephobjectstores/status",
          "cephobjectstoreusers/status",
          "cephobjectrealms/status",
          "cephobjectzonegroups/status",
          "cephobjectzones/status",
          "cephbuckettopics/status",
          "cephbucketnotifications/status",
          "cephrbdmirrors/status",
          "cephfilesystemmirrors/status",
          "cephfilesystemsubvolumegroups/status",
          "cephblockpoolradosnamespaces/status",
        ]
        "verbs" = [
          "update",
        ]
      },
      {
        "apiGroups" = [
          "ceph.rook.io",
        ]
        "resources" = [
          "cephclients/finalizers",
          "cephclusters/finalizers",
          "cephblockpools/finalizers",
          "cephfilesystems/finalizers",
          "cephnfses/finalizers",
          "cephobjectstores/finalizers",
          "cephobjectstoreusers/finalizers",
          "cephobjectrealms/finalizers",
          "cephobjectzonegroups/finalizers",
          "cephobjectzones/finalizers",
          "cephbuckettopics/finalizers",
          "cephbucketnotifications/finalizers",
          "cephrbdmirrors/finalizers",
          "cephfilesystemmirrors/finalizers",
          "cephfilesystemsubvolumegroups/finalizers",
          "cephblockpoolradosnamespaces/finalizers",
        ]
        "verbs" = [
          "update",
        ]
      },
      {
        "apiGroups" = [
          "policy",
          "apps",
          "extensions",
        ]
        "resources" = [
          "poddisruptionbudgets",
          "deployments",
          "replicasets",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
          "deletecollection",
        ]
      },
      {
        "apiGroups" = [
          "healthchecking.openshift.io",
        ]
        "resources" = [
          "machinedisruptionbudgets",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "machine.openshift.io",
        ]
        "resources" = [
          "machines",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "storage.k8s.io",
        ]
        "resources" = [
          "csidrivers",
        ]
        "verbs" = [
          "create",
          "delete",
          "get",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "k8s.cni.cncf.io",
        ]
        "resources" = [
          "network-attachment-definitions",
        ]
        "verbs" = [
          "get",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_rook_ceph_mgr_cluster" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/part-of" = "rook-ceph-operator"
        "operator" = "rook"
        "storage-backend" = "ceph"
      }
      "name" = "rook-ceph-mgr-cluster"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
          "nodes",
          "nodes/proxy",
          "persistentvolumes",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "events",
        ]
        "verbs" = [
          "create",
          "patch",
          "list",
          "get",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "storage.k8s.io",
        ]
        "resources" = [
          "storageclasses",
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

resource "kubernetes_manifest" "clusterrole_rook_ceph_mgr_system" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "rook-ceph-mgr-system"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
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

resource "kubernetes_manifest" "clusterrole_rook_ceph_object_bucket" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/part-of" = "rook-ceph-operator"
        "operator" = "rook"
        "storage-backend" = "ceph"
      }
      "name" = "rook-ceph-object-bucket"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "secrets",
          "configmaps",
        ]
        "verbs" = [
          "get",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "storage.k8s.io",
        ]
        "resources" = [
          "storageclasses",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "objectbucket.io",
        ]
        "resources" = [
          "objectbucketclaims",
        ]
        "verbs" = [
          "list",
          "watch",
          "get",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "objectbucket.io",
        ]
        "resources" = [
          "objectbuckets",
        ]
        "verbs" = [
          "list",
          "watch",
          "get",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "objectbucket.io",
        ]
        "resources" = [
          "objectbucketclaims/status",
          "objectbuckets/status",
        ]
        "verbs" = [
          "update",
        ]
      },
      {
        "apiGroups" = [
          "objectbucket.io",
        ]
        "resources" = [
          "objectbucketclaims/finalizers",
          "objectbuckets/finalizers",
        ]
        "verbs" = [
          "update",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_rook_ceph_osd" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "rook-ceph-osd"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_rook_ceph_system" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/part-of" = "rook-ceph-operator"
        "operator" = "rook"
        "storage-backend" = "ceph"
      }
      "name" = "rook-ceph-system"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "pods/log",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods/exec",
        ]
        "verbs" = [
          "create",
        ]
      },
      {
        "apiGroups" = [
          "admissionregistration.k8s.io",
        ]
        "resources" = [
          "validatingwebhookconfigurations",
        ]
        "verbs" = [
          "create",
          "get",
          "delete",
          "update",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_cephfs_csi_provisioner_role" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "cephfs-csi-provisioner-role"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "cephfs-external-provisioner-runner"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-csi-cephfs-provisioner-sa"
        "namespace" = local.namespace
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_rbd_csi_nodeplugin" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "rbd-csi-nodeplugin"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "rbd-csi-nodeplugin"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-csi-rbd-plugin-sa"
        "namespace" = local.namespace
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_rbd_csi_provisioner_role" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "rbd-csi-provisioner-role"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "rbd-external-provisioner-runner"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-csi-rbd-provisioner-sa"
        "namespace" = local.namespace
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_rook_ceph_global" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/part-of" = "rook-ceph-operator"
        "operator" = "rook"
        "storage-backend" = "ceph"
      }
      "name" = "rook-ceph-global"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "rook-ceph-global"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-ceph-system"
        "namespace" = local.namespace
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_rook_ceph_mgr_cluster" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "rook-ceph-mgr-cluster"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "rook-ceph-mgr-cluster"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-ceph-mgr"
        "namespace" = local.namespace
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_rook_ceph_object_bucket" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "rook-ceph-object-bucket"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "rook-ceph-object-bucket"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-ceph-system"
        "namespace" = local.namespace
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_rook_ceph_osd" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "rook-ceph-osd"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "rook-ceph-osd"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-ceph-osd"
        "namespace" = local.namespace
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_rook_ceph_system" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/part-of" = "rook-ceph-operator"
        "operator" = "rook"
        "storage-backend" = "ceph"
      }
      "name" = "rook-ceph-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "rook-ceph-system"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "rook-ceph-system"
        "namespace" = local.namespace
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_cephfs_external_provisioner_cfg" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "cephfs-external-provisioner-cfg"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "coordination.k8s.io",
        ]
        "resources" = [
          "leases",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
          "delete",
          "update",
          "create",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rbd_csi_nodeplugin" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rbd-csi-nodeplugin"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "csiaddons.openshift.io",
        ]
        "resources" = [
          "csiaddonsnodes",
        ]
        "verbs" = [
          "create",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rbd_external_provisioner_cfg" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rbd-external-provisioner-cfg"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "coordination.k8s.io",
        ]
        "resources" = [
          "leases",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
          "delete",
          "update",
          "create",
        ]
      },
      {
        "apiGroups" = [
          "csiaddons.openshift.io",
        ]
        "resources" = [
          "csiaddonsnodes",
        ]
        "verbs" = [
          "create",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_cmd_reporter" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rook-ceph-cmd-reporter"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "configmaps",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_mgr" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rook-ceph-mgr"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "services",
          "pods/log",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "jobs",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "ceph.rook.io",
        ]
        "resources" = [
          "cephclients",
          "cephclusters",
          "cephblockpools",
          "cephfilesystems",
          "cephnfses",
          "cephobjectstores",
          "cephobjectstoreusers",
          "cephobjectrealms",
          "cephobjectzonegroups",
          "cephobjectzones",
          "cephbuckettopics",
          "cephbucketnotifications",
          "cephrbdmirrors",
          "cephfilesystemmirrors",
          "cephfilesystemsubvolumegroups",
          "cephblockpoolradosnamespaces",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "apps",
        ]
        "resources" = [
          "deployments/scale",
          "deployments",
        ]
        "verbs" = [
          "patch",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "persistentvolumeclaims",
        ]
        "verbs" = [
          "delete",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_osd" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rook-ceph-osd"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "secrets",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "ceph.rook.io",
        ]
        "resources" = [
          "cephclusters",
          "cephclusters/finalizers",
        ]
        "verbs" = [
          "get",
          "list",
          "create",
          "update",
          "delete",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_purge_osd" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rook-ceph-purge-osd"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "apps",
        ]
        "resources" = [
          "deployments",
        ]
        "verbs" = [
          "get",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "jobs",
        ]
        "verbs" = [
          "get",
          "list",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "persistentvolumeclaims",
        ]
        "verbs" = [
          "get",
          "update",
          "delete",
          "list",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_rgw" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "rook-ceph-rgw"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "get",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_rook_ceph_rook_ceph_system" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/part-of" = "rook-ceph-operator"
        "operator" = "rook"
        "storage-backend" = "ceph"
      }
      "name" = "rook-ceph-system"
      "namespace" = local.namespace
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "configmaps",
          "services",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "patch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "apps",
          "extensions",
        ]
        "resources" = [
          "daemonsets",
          "statefulsets",
          "deployments",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
          "create",
          "update",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "cronjobs",
        ]
        "verbs" = [
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "cert-manager.io",
        ]
        "resources" = [
          "certificates",
          "issuers",
        ]
        "verbs" = [
          "get",
          "create",
          "delete",
        ]
      },
    ]
  }
}

resource "kubernetes_role_binding" "cephfs_csi_provisioner_role_cfg" {
  metadata {
    name = "cephfs-csi-provisioner-role-cfg"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "cephfs-external-provisioner-cfg"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-csi-cephfs-provisioner-sa"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rbd_csi_nodeplugin_role_cfg" {
  metadata {
    name = "rbd-csi-nodeplugin-role-cfg"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rbd-csi-nodeplugin"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-csi-rbd-plugin-sa"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rbd_csi_provisioner_role_cfg" {
  metadata {
    name = "rbd-csi-provisioner-role-cfg"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rbd-external-provisioner-cfg"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-csi-rbd-provisioner-sa"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rook_ceph_cluster_mgmt" {
  metadata {
    name = "rook-ceph-cluster-mgmt"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "rook-ceph-cluster-mgmt"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-ceph-system"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rook_ceph_cmd_reporter" {
  metadata {
    name = "rook-ceph-cmd-reporter"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rook-ceph-cmd-reporter"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-ceph-cmd-reporter"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rook_ceph_mgr" {
  metadata {
    name = "rook-ceph-mgr"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rook-ceph-mgr"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-ceph-mgr"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rook_ceph_mgr_system" {
  metadata {
    name = "rook-ceph-mgr-system"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "rook-ceph-mgr-system"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-ceph-mgr"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rook_ceph_osd" {
  metadata {
    name = "rook-ceph-osd"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rook-ceph-osd"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-ceph-osd"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rook_ceph_purge_osd" {
  metadata {
    name = "rook-ceph-purge-osd"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rook-ceph-purge-osd"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-ceph-purge-osd"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rook_ceph_rgw" {
  metadata {
    name = "rook-ceph-rgw"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rook-ceph-rgw"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-ceph-rgw"
    namespace = local.namespace
  }
}

resource "kubernetes_role_binding" "rook_ceph_system" {
  metadata {
    name = "rook-ceph-system"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/part-of" = "rook-ceph-operator"
      "operator" = "rook"
      "storage-backend" = "ceph"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "rook-ceph-system"
  }
  subject {
    kind = "ServiceAccount"
    name = "rook-ceph-system"
    namespace = local.namespace
  }
}

resource "kubernetes_service_account" "rook_ceph_cmd_reporter" {
  metadata {
    name = "rook-ceph-cmd-reporter"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/part-of" = "rook-ceph-operator"
      "operator" = "rook"
      "storage-backend" = "ceph"
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_ceph_mgr" {
  metadata {
    name = "rook-ceph-mgr"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/part-of" = "rook-ceph-operator"
      "operator" = "rook"
      "storage-backend" = "ceph"
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_ceph_osd" {
  metadata {
    name = "rook-ceph-osd"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/part-of" = "rook-ceph-operator"
      "operator" = "rook"
      "storage-backend" = "ceph"
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_ceph_purge_osd" {
  metadata {
    name = "rook-ceph-purge-osd"
    namespace = local.namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_ceph_rgw" {
  metadata {
    name = "rook-ceph-rgw"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/part-of" = "rook-ceph-operator"
      "operator" = "rook"
      "storage-backend" = "ceph"
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_ceph_system" {
  metadata {
    name = "rook-ceph-system"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/part-of" = "rook-ceph-operator"
      "operator" = "rook"
      "storage-backend" = "ceph"
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_csi_cephfs_plugin_sa" {
  metadata {
    name = "rook-csi-cephfs-plugin-sa"
    namespace = local.namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_csi_cephfs_provisioner_sa" {
  metadata {
    name = "rook-csi-cephfs-provisioner-sa"
    namespace = local.namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_csi_rbd_plugin_sa" {
  metadata {
    name = "rook-csi-rbd-plugin-sa"
    namespace = local.namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "rook_csi_rbd_provisioner_sa" {
  metadata {
    name = "rook-csi-rbd-provisioner-sa"
    namespace = local.namespace
  }
  automount_service_account_token = false
}

output "namespace" {
  value = local.namespace
}
