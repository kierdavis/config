package rookceph

import (
	"cue.skaia/hosts"
)

resources: configmaps: "rook-ceph": "rook-ceph-operator-config": data: CSI_PROVISIONER_REPLICAS: "1"
resources: deployments: "rook-ceph": "rook-ceph-operator": spec: template: spec: priorityClassName: "system-cluster-critical"
resources: deployments: "rook-ceph": "rook-ceph-tools": spec: template: spec: priorityClassName: "system-cluster-critical"

resources: nodes: "": {
	for hostName, host in hosts.hosts
	if host.isKubeNode
	{
		"\(hostName)": metadata: labels: {
			for key, value in host.cephCrushLabels
			{
				"topology.rook.io/\(key)": value
			}
		}
	}
}

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
	}
}
resources: storageclasses: "": "ceph-fs-replicated": {
	provisioner: "rook-ceph.cephfs.csi.ceph.com"
	reclaimPolicy: "Delete"
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
