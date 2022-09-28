terraform {
  required_providers {
    ceph = {
      source = "cernops/ceph"
      version = "~> 0.1.4"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.2"
    }
  }
}

resource "kubernetes_manifest" "cluster" {
  manifest = {
    "apiVersion" = "ceph.rook.io/v1"
    "kind" = "CephCluster"
    "metadata" = {
      "name" = "hist5"
      "namespace" = "rook-ceph"
    }
    "spec" = {
      "cephVersion" = {
        "allowUnsupported" = false
        "image" = "quay.io/ceph/ceph:v17.2.3"
      }
      "cleanupPolicy" = {
        "allowUninstallWithVolumes" = false
        "confirmation" = ""
        "sanitizeDisks" = {
          "dataSource" = "zero"
          "iteration" = 1
          "method" = "quick"
        }
      }
      "continueUpgradeAfterChecksEvenIfNotHealthy" = false
      "crashCollector" = {
        "disable" = false
      }
      "dashboard" = {
        "enabled" = true
        "ssl" = false
      }
      "dataDirHostPath" = "/var/lib/rook"
      "disruptionManagement" = {
        "machineDisruptionBudgetNamespace" = "openshift-machine-api"
        "manageMachineDisruptionBudgets" = false
        "managePodBudgets" = true
        "osdMaintenanceTimeout" = 30
        "pgHealthCheckTimeout" = 0
      }
      "healthCheck" = {
        "daemonHealth" = {
          "mon" = {
            "disabled" = false
            "interval" = "45s"
          }
          "osd" = {
            "disabled" = false
            "interval" = "1m0s"
          }
          "status" = {
            "disabled" = false
            "interval" = "1m0s"
          }
        }
        "livenessProbe" = {
          "mgr" = {
            "disabled" = false
          }
          "mon" = {
            "disabled" = false
          }
          "osd" = {
            "disabled" = false
          }
        }
        "startupProbe" = {
          "mgr" = {
            "disabled" = false
          }
          "mon" = {
            "disabled" = false
          }
          "osd" = {
            "disabled" = false
          }
        }
      }
      "mgr" = {
        "allowMultiplePerNode" = false
        "count" = 2
        "modules" = [
          { "name" = "pg_autoscaler", "enabled" = true },
          { "name" = "prometheus", "enabled" = true },
          { "name" = "rook", "enabled" = true },
        ]
      }
      "mon" = {
        "allowMultiplePerNode" = false
        "count" = 3
      }
      "monitoring" = {
        "enabled" = false
      }
      "network" = {
        "connections" = {
          "compression" = {
            "enabled" = false
          }
          "encryption" = {
            "enabled" = false
          }
        }
      }
      "priorityClassNames" = {
        "mgr" = "system-cluster-critical"
        "mon" = "system-node-critical"
        "osd" = "system-node-critical"
      }
      "removeOSDsIfOutAndSafeToRemove" = false
      "skipUpgradeChecks" = false
      "storage" = {
        "onlyApplyOSDPlacement" = false
        "useAllDevices" = false
        "devicePathFilter" = "^/dev/disk/by-id/[^/]*ceph"
        "useAllNodes" = true
      }
      "waitTimeoutForHealthyOSDInMinutes" = 10
    }
  }
}

resource "kubernetes_manifest" "cephblockpool_replicated_0_metadata" {
  manifest = {
    "apiVersion" = "ceph.rook.io/v1"
    "kind" = "CephBlockPool"
    "metadata" = {
      "name" = "blk-replicated-0-metadata"
      "namespace" = "rook-ceph"
    }
    "spec" = {
      "failureDomain" = "host"
      "replicated" = { "size" = 2 }
      "parameters" = {
        "bulk" = "0"
        "pg_num_min" = "1"
      }
    }
  }
}

resource "kubernetes_manifest" "cephblockpool_replicated_0_data" {
  manifest = {
    "apiVersion" = "ceph.rook.io/v1"
    "kind" = "CephBlockPool"
    "metadata" = {
      "name" = "blk-replicated-0-data"
      "namespace" = "rook-ceph"
    }
    "spec" = {
      "failureDomain" = "host"
      "erasureCoded" = { "dataChunks" = 2, "codingChunks" = 1 }
      "parameters" = {
        "bulk" = "1"
        "pg_num_min" = "1"
      }
    }
  }
}

resource "kubernetes_storage_class" "ceph_blk_replicated_0" {
  metadata {
    name = "ceph-blk-replicated-0"
  }
  storage_provisioner = "rook-ceph.rbd.csi.ceph.com"
  reclaim_policy = "Delete"
  allow_volume_expansion = true
  parameters = {
    clusterID = "rook-ceph"
    pool = kubernetes_manifest.cephblockpool_replicated_0_metadata.manifest.metadata.name
    dataPool = kubernetes_manifest.cephblockpool_replicated_0_data.manifest.metadata.name
    "csi.storage.k8s.io/fstype" = "ext4"
    "csi.storage.k8s.io/provisioner-secret-name" = "rook-csi-rbd-provisioner"
    "csi.storage.k8s.io/provisioner-secret-namespace" = "rook-ceph"
    "csi.storage.k8s.io/controller-expand-secret-name" = "rook-csi-rbd-provisioner"
    "csi.storage.k8s.io/controller-expand-secret-namespace" = "rook-ceph"
    "csi.storage.k8s.io/node-stage-secret-name" = "rook-csi-rbd-node"
    "csi.storage.k8s.io/node-stage-secret-namespace" = "rook-ceph"
  }
}

resource "kubernetes_manifest" "cephfilesystem_replicated_0" {
  manifest = {
    "apiVersion" = "ceph.rook.io/v1"
    "kind" = "CephFilesystem"
    "metadata" = {
      "name" = "fs-replicated-0"
      "namespace" = "rook-ceph"
    }
    "spec" = {
      "metadataPool" = {
        "failureDomain" = "host"
        "replicated" = { "size" = 2 }
        "parameters" = {
          "bulk" = "0"
          "pg_num_min" = "1"
        }
      }
      "dataPools" = [
        # https://tracker.ceph.com/issues/42450
        # The first (default) pool contains gluey inode backtrace stuff and must be replicated.
        # All the file contents will actually be stored in the second pool.
        {
          "name" = "inode-backtraces"
          "failureDomain" = "host"
          "replicated" = { "size" = 2 }
          "parameters" = {
            "bulk" = "0"
            "pg_num_min" = "1"
          }
        },
        {
          "name" = "data"
          "failureDomain" = "host"
          "erasureCoded" = { "dataChunks" = 2, "codingChunks" = 1 }
          "parameters" = {
            "bulk" = "1"
            "pg_num_min" = "1"
          }
        },
      ]
      "metadataServer" = {
        "activeCount" = 1  # Controls sharding, not redundancy.
        "priorityClassName" = "system-cluster-critical"
      }
    }
  }
}

resource "kubernetes_storage_class" "ceph_fs_replicated_0" {
  metadata {
    name = "ceph-fs-replicated-0"
  }
  storage_provisioner = "rook-ceph.cephfs.csi.ceph.com"
  reclaim_policy = "Delete"
  parameters = {
    clusterID = "rook-ceph"
    fsName = kubernetes_manifest.cephfilesystem_replicated_0.manifest.metadata.name
    pool = "${kubernetes_manifest.cephfilesystem_replicated_0.manifest.metadata.name}-data"
    "csi.storage.k8s.io/provisioner-secret-name" = "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/provisioner-secret-namespace" = "rook-ceph"
    "csi.storage.k8s.io/controller-expand-secret-name" = "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/controller-expand-secret-namespace" = "rook-ceph"
    "csi.storage.k8s.io/node-stage-secret-name" = "rook-csi-cephfs-node"
    "csi.storage.k8s.io/node-stage-secret-namespace" = "rook-ceph"
  }
}

resource "kubernetes_manifest" "cephobjectstore_nonvolatile_0" {
  manifest = {
    "apiVersion" = "ceph.rook.io/v1"
    "kind" = "CephObjectStore"
    "metadata" = {
      "name" = "obj-nonvolatile-0"
      "namespace" = "rook-ceph"
    }
    "spec" = {
      "metadataPool" = {
        "failureDomain" = "host"
        "replicated" = { "size" = 2 }
        # XXX: The CRD doesn't specify a schema for the parameters sub-tree,
        # and for some reason this means that the kubernetes_manifest will treat
        # any change to this sub-tree as requiring full resource re-creation.
        # Ref: https://github.com/hashicorp/terraform-provider-kubernetes/pull/1646
        # We can sort of work around this by an Indiana Jones-style bait-and-switch:
        # Shut down the operator, delete the CephObjectStore's finaliser, letting
        # Terraform destroy and recreate the CephObjectStore, then start the operator
        # back up.
        "parameters" = {
          "bulk" = "0"
          "pg_num_min" = "1"
        }
      }
      "dataPool" = {
        "failureDomain" = "host"
        "erasureCoded" = { "dataChunks" = 2, "codingChunks" = 1 }
        "parameters" = {
          "bulk" = "1"
          "pg_num_min" = "1"
        }
      }
      "preservePoolsOnDelete" = false
      "gateway" = {
        "port" = 80
        "instances" = 2
      }
    }
  }
}

resource "kubernetes_storage_class" "ceph_obj_nonvolatile_0" {
  metadata {
    name = "ceph-obj-nonvolatile-0"
  }
  storage_provisioner = "rook-ceph.ceph.rook.io/bucket"
  reclaim_policy = "Delete"
  parameters = {
    objectStoreNamespace = kubernetes_manifest.cephobjectstore_nonvolatile_0.manifest.metadata.namespace
    objectStoreName = kubernetes_manifest.cephobjectstore_nonvolatile_0.manifest.metadata.name
  }
}

output "storage_classes" {
  value = {
    ceph_blk_replicated_0 = kubernetes_storage_class.ceph_blk_replicated_0.metadata[0].name
    ceph_fs_replicated_0 = kubernetes_storage_class.ceph_fs_replicated_0.metadata[0].name
    ceph_obj_nonvolatile_0 = kubernetes_storage_class.ceph_obj_nonvolatile_0.metadata[0].name
  }
}

data "kubernetes_secret" "ceph_config" {
  metadata {
    name = "rook-ceph-config"
    namespace = "rook-ceph"
  }
}

resource "ceph_auth" "mount_universal" {
  entity = "client.hist5-mount-universal"
  caps = {
    mds = "allow rw"
    # mgr = "allow rw"
    mon = "allow r"
    osd = "allow rw tag cephfs *=*"
  }
}

resource "local_file" "output" {
  filename = "../../secret/hist5/cue/autogenerated_ceph_secrets.cue"
  file_permission = "0644"
  content = join("\n", ["package hist5", jsonencode({
    ceph = {
      auth = {
        mountUniversal = {
          name = ceph_auth.mount_universal.entity
          clientName = split(".", ceph_auth.mount_universal.entity)[1]
          secretKey = ceph_auth.mount_universal.key
        }
      }
    }
  })])
}
