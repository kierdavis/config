package rookceph

import (
	"encoding/yaml"
)

resources: configmaps: "rook-ceph": "rook-ceph-operator-config": data: {
	CSI_PROVISIONER_REPLICAS: "1"
	CSI_CEPHFS_PLUGIN_RESOURCE: yaml.Marshal([{
		name: "csi-cephfsplugin"
		resource: requests: cpu: "1m"
		resource: requests: memory: "16Mi"
	}, {
		name: "driver-registrar"
		resource: requests: cpu: "1m"
		resource: requests: memory: "5Mi"
	}])
	CSI_CEPHFS_PROVISIONER_RESOURCE: yaml.Marshal([{
		name: "csi-attacher"
		resource: requests: cpu: "1m"
		resource: requests: memory: "9Mi"
	}, {
		name: "csi-cephfsplugin"
		resource: requests: cpu: "1m"
		resource: requests: memory: "16Mi"
	}, {
		name: "csi-provisioner"
		resource: requests: cpu: "2m"
		resource: requests: memory: "11Mi"
	}, {
		name: "csi-resizer"
		resource: requests: cpu: "1m"
		resource: requests: memory: "9Mi"
	}, {
		name: "csi-snapshotter"
		resource: requests: cpu: "8m"
		resource: requests: memory: "9Mi"
	}])
	CSI_RBD_PLUGIN_RESOURCE: yaml.Marshal([{
		name: "csi-rbdplugin"
		resource: requests: cpu: "2m"
		resource: requests: memory: "30Mi"
	}, {
		name: "driver-registrar"
		resource: requests: cpu: "1m"
		resource: requests: memory: "5Mi"
	}])
	CSI_RBD_PROVISIONER_RESOURCE: yaml.Marshal([{
		name: "csi-attacher"
		resource: requests: cpu: "1m"
		resource: requests: memory: "9Mi"
	}, {
		name: "csi-provisioner"
		resource: requests: cpu: "1m"
		resource: requests: memory: "11Mi"
	}, {
		name: "csi-rbdplugin"
		resource: requests: cpu: "1m"
		resource: requests: memory: "30Mi"
	}, {
		name: "csi-resizer"
		resource: requests: cpu: "1m"
		resource: requests: memory: "9Mi"
	}, {
		name: "csi-snapshotter"
		resource: requests: cpu: "2m"
		resource: requests: memory: "9Mi"
	}])
}
resources: deployments: "rook-ceph": "rook-ceph-operator": spec: template: spec: priorityClassName: "system-cluster-critical"
resources: deployments: "rook-ceph": "rook-ceph-tools": spec: template: spec: priorityClassName: "system-cluster-critical"

// The blank line before the closing triple quote is important.
resources: configmaps: "rook-ceph": "rook-config-override": data: config: """
	[global]
	osd_pool_default_size = 2

	"""

resources: cephclusters: "rook-ceph": "default": spec: {
	cephVersion: {
		image: "quay.io/ceph/ceph:v17.2.5"
		allowUnsupported: false
	}
	dataDirHostPath: "/var/lib/rook"
	skipUpgradeChecks: false
	continueUpgradeAfterChecksEvenIfNotHealthy: false
	waitTimeoutForHealthyOSDInMinutes: 10
	mon: {
		count: 3
		allowMultiplePerNode: false
	}
	mgr: {
		count: 2
		allowMultiplePerNode: false
		modules: [
			{ name: "pg_autoscaler", enabled: true },
			{ name: "prometheus", enabled: true },
			{ name: "rook", enabled: true },
		]
	}
	dashboard: {
		enabled: true
		port: 80
		ssl: false
	}
	monitoring: enabled: false
	network: connections: encryption: enabled: false
	network: connections: compression: enabled: false
	crashCollector: disable: false
	logCollector: enabled: false
	cleanupPolicy: {
		confirmation: ""
		sanitizeDisks: {
			method: "quick"
			dataSource: "zero"
			iteration: 1
		}
		allowUninstallWithVolumes: false
	}
	removeOSDsIfOutAndSafeToRemove: false
	priorityClassNames: {
		crashcollector: "observability"
		mgr: "system-cluster-critical"
		mon: "system-node-critical"
		osd: "system-node-critical"
	}
	resources: {
		crashcollector: {
			requests: cpu: "1m"
			requests: memory: "10Mi"
			limits: memory: "60Mi"
		}
		mgr: {
			requests: cpu: "50m"
			requests: memory: "600Mi"
			limits: memory: "600Mi"
		}
		"mgr-sidecar": {
			requests: cpu: "50m"
			requests: memory: "40Mi"
			limits: memory: "100Mi"
		}
		//mon: {
		//	requests: cpu: "50m"
		//	requests: memory: "1024Mi"
		//	limits: memory: "1024Mi"
		//}
		osd: {
			requests: cpu: "100m"
			requests: memory: "1536Mi"
			limits: memory: "1536Mi"
		}
	}
	storage: {
		useAllNodes: true
		useAllDevices: true
	}
	disruptionManagement: {
		managePodBudgets: true
		osdMaintenanceTimeout: 30
		pgHealthCheckTimeout: 0
		manageMachineDisruptionBudgets: false
	}
	healthCheck: {
		[string]: [string]: {
			disabled: false
			probe: {
				initialDelaySeconds: 10
				periodSeconds: 30
				timeoutSeconds: 25
				failureThreshold: >=0
				successThreshold: 1
				terminationGracePeriodSeconds: 60
			}
		}
		[string]: mgr: {}
		[string]: mon: {}
		[string]: osd: {}
		livenessProbe: [string]: probe: failureThreshold: 3
		startupProbe: [string]: probe: failureThreshold: 720
	}
}

defaultScratchMetadataPoolSpec: {
	replicated: size: 1
	failureDomain: "osd"
	parameters: {
		bulk: "0"
		pg_num_min: "1"
	}
}

defaultScratchDataPoolSpec: {
	replicated: size: 1
	failureDomain: "osd"
	parameters: {
		bulk: "1"
		pg_num_min: "1"
	}
}

defaultMetadataPoolSpec: {
	replicated: size: 2
	failureDomain: "osd"
	parameters: {
		bulk: "0"
		pg_num_min: "1"
	}
}

defaultDataPoolSpec: {
	replicated: size: 2
	failureDomain: "osd"
	parameters: {
		bulk: "1"
		pg_num_min: "1"
	}
}

dummyStuffToMakeServerSideApplyHappy: {
	erasureCoded: codingChunks: 0
	erasureCoded: dataChunks: 0
	mirroring: {}
	quotas: {}
	statusCheck: mirror: {}
}

resources: cephblockpools: "rook-ceph": "blk-replicated-metadata": spec: defaultMetadataPoolSpec
resources: cephblockpools: "rook-ceph": "blk-replicated-data": spec: defaultDataPoolSpec
resources: storageclasses: "": "ceph-blk-replicated": {
	provisioner: "rook-ceph.rbd.csi.ceph.com"
	reclaimPolicy: "Delete"
	allowVolumeExpansion: true
	parameters: {
		clusterID: "rook-ceph"
		pool: "blk-replicated-metadata"
		dataPool: "blk-replicated-data"
		"csi.storage.k8s.io/fstype": "ext4"
		"csi.storage.k8s.io/provisioner-secret-name": "rook-csi-rbd-provisioner"
		"csi.storage.k8s.io/provisioner-secret-namespace": "rook-ceph"
		"csi.storage.k8s.io/controller-expand-secret-name": "rook-csi-rbd-provisioner"
		"csi.storage.k8s.io/controller-expand-secret-namespace": "rook-ceph"
		"csi.storage.k8s.io/node-stage-secret-name": "rook-csi-rbd-node"
		"csi.storage.k8s.io/node-stage-secret-namespace": "rook-ceph"
	}
}

resources: cephfilesystems: "rook-ceph": "fs-replicated": spec: {
	metadataPool: defaultMetadataPoolSpec
	dataPools: [
		// https://tracker.ceph.com/issues/42450
		// The first (default) pool contains gluey inode backtrace stuff and must be replicated.
		// All the file contents will actually be stored in the second pool.
		{ name: "inode-backtraces" } & defaultMetadataPoolSpec & dummyStuffToMakeServerSideApplyHappy,
		{ name: "data" } & defaultDataPoolSpec & dummyStuffToMakeServerSideApplyHappy,
	]
	metadataServer: {
		activeCount: 1  // Controls sharding, not redundancy.
		priorityClassName: "system-cluster-critical"
		resources: {
			requests: cpu: "150m"
			requests: memory: "100Mi"
			limits: memory: "150Mi"
		}
	}
}
resources: storageclasses: "": "ceph-fs-replicated": {
	provisioner: "rook-ceph.cephfs.csi.ceph.com"
	reclaimPolicy: "Delete"
	allowVolumeExpansion: true
	parameters: {
		clusterID: "rook-ceph"
		fsName: "fs-replicated"
		pool: "fs-replicated-data"
		"csi.storage.k8s.io/provisioner-secret-name": "rook-csi-cephfs-provisioner"
		"csi.storage.k8s.io/provisioner-secret-namespace": "rook-ceph"
		"csi.storage.k8s.io/controller-expand-secret-name": "rook-csi-cephfs-provisioner"
		"csi.storage.k8s.io/controller-expand-secret-namespace": "rook-ceph"
		"csi.storage.k8s.io/node-stage-secret-name": "rook-csi-cephfs-node"
		"csi.storage.k8s.io/node-stage-secret-namespace": "rook-ceph"
	}
}
// UID/GID used for files on CephFS filesystems where permissioning doesn't matter.
sharedFilesystemUid: 2000
