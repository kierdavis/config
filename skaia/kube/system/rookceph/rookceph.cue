package rookceph

import (
	"cue.skaia/hosts"
	"cue.skaia/kube/schema"
)

resources: schema.resources

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
		count: 1
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
}

resources: cephblockpools: "rook-ceph": "blk-replicated-metadata": spec: {
	failureDomain: "host"
	replicated: size: 2
	parameters: {
		bulk: "0"
		pg_num_min: "1"
	}
}

resources: cephblockpools: "rook-ceph": "blk-replicated-data": spec: {
	failureDomain: "host"
	replicated: size: 2
	parameters: {
		bulk: "1"
		pg_num_min: "1"
	}
}

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
