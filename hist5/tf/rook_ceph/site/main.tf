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

resource "kubernetes_manifest" "cluster" {
  manifest = {
    "apiVersion" = "ceph.rook.io/v1"
    "kind" = "CephCluster"
    "metadata" = {
      "name" = "hist5"
      "namespace" = var.namespace
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

resource "kubernetes_manifest" "cephobjectstore_nonvolatile_0" {
  manifest = {
    "apiVersion" = "ceph.rook.io/v1"
    "kind" = "CephObjectStore"
    "metadata" = {
      "name" = "nonvolatile-0"
      "namespace" = var.namespace
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
          "pg_num_min" = "4"
        }
      }
      "dataPool" = {
        "failureDomain" = "host"
        "erasureCoded" = { "dataChunks" = 2, "codingChunks" = 1 }
        "parameters" = {
          "bulk" = "1"
          "pg_num_min" = "4"
        }
      }
      "preservePoolsOnDelete" = false
      "gateway" = {
        "port" = 80
        "instances" = 3
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
    ceph_obj_nonvolatile_0 = kubernetes_storage_class.ceph_obj_nonvolatile_0.metadata[0].name
  }
}
