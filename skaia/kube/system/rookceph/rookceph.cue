package rookceph

import (
	"cue.skaia/kube/schema"
)

resources: schema.resources

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
		mon: "system-node-critical"
		osd: "system-node-critical"
		mgr: "system-cluster-critical"
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
