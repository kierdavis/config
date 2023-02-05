package rookceph

import (
	"encoding/yaml"
)

resources: configmaps: "rook-ceph": "rook-ceph-operator-config": data: {
	CSI_PROVISIONER_REPLICAS: "1"
	CSI_CEPHFS_PLUGIN_RESOURCE: yaml.Marshal([{
		name: "csi-cephfsplugin"
		resource: requests: cpu: "1m"
		resource: requests: memory: "50Mi"
	}, {
		name: "driver-registrar"
		resource: requests: cpu: "1m"
		resource: requests: memory: "6Mi"
	}])
	CSI_CEPHFS_PROVISIONER_RESOURCE: yaml.Marshal([{
		name: "csi-attacher"
		resource: requests: cpu: "1m"
		resource: requests: memory: "15Mi"
	}, {
		name: "csi-cephfsplugin"
		resource: requests: cpu: "1m"
		resource: requests: memory: "18Mi"
	}, {
		name: "csi-provisioner"
		resource: requests: cpu: "2m"
		resource: requests: memory: "18Mi"
	}, {
		name: "csi-resizer"
		resource: requests: cpu: "1m"
		resource: requests: memory: "15Mi"
	}, {
		name: "csi-snapshotter"
		resource: requests: cpu: "8m"
		resource: requests: memory: "15Mi"
	}])
	CSI_RBD_PLUGIN_RESOURCE: yaml.Marshal([{
		name: "csi-rbdplugin"
		resource: requests: cpu: "2m"
		resource: requests: memory: "60Mi"
	}, {
		name: "driver-registrar"
		resource: requests: cpu: "1m"
		resource: requests: memory: "9Mi"
	}])
	CSI_RBD_PROVISIONER_RESOURCE: yaml.Marshal([{
		name: "csi-attacher"
		resource: requests: cpu: "1m"
		resource: requests: memory: "15Mi"
	}, {
		name: "csi-provisioner"
		resource: requests: cpu: "1m"
		resource: requests: memory: "18Mi"
	}, {
		name: "csi-rbdplugin"
		resource: requests: cpu: "1m"
		resource: requests: memory: "32Mi"
	}, {
		name: "csi-resizer"
		resource: requests: cpu: "1m"
		resource: requests: memory: "15Mi"
	}, {
		name: "csi-snapshotter"
		resource: requests: cpu: "3m"
		resource: requests: memory: "15Mi"
	}])
}

resources: deployments: "rook-ceph": "rook-ceph-operator": spec: template: spec: {
	priorityClassName: "system-cluster-critical"
	containers: [{
		name: "rook-ceph-operator"  // assert we're operating on the expected element of the list
		resources: requests: cpu: "150m"
		resources: requests: memory: "80Mi"
	}]
}

resources: deployments: "rook-ceph": "rook-ceph-tools": spec: template: spec: {
	priorityClassName: "system-cluster-critical"
	containers: [{
		name: "rook-ceph-tools"  // assert we're operating on the expected element of the list
		resources: requests: cpu: "5m"
		resources: requests: memory: "50Mi"
	}]
}

// The blank line before the closing triple quote is important.
resources: configmaps: "rook-ceph": "rook-config-override": data: config: """
	[global]
	osd_pool_default_size = 2

	"""

resources: serviceaccounts: "rook-ceph": "imperative-config": {}
resources: roles: "rook-ceph": "imperative-config": rules: [
	{ apiGroups: [""], resources: ["pods"], verbs: ["get", "list"] },
	{ apiGroups: [""], resources: ["pods/exec"], verbs: ["create"] },
]
resources: rolebindings: "rook-ceph": "imperative-config": {
	subjects: [{
		kind: "ServiceAccount"
		name: "imperative-config"
		namespace: "rook-ceph"
	}]
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind: "Role"
		name: "imperative-config"
	}
}
resources: jobs: "rook-ceph": "imperative-config": spec: {
	backoffLimit: 0
	template: {
		metadata: labels: app: "imperative-config"
		spec: {
			restartPolicy: "Never"
			serviceAccountName: "imperative-config"
			containers: [{
				name: "main"
				image: "bitnami/kubectl"
				command: ["/bin/bash", "-c"]
				args: ["""
					set -o errexit -o nounset -o pipefail -o xtrace
					tools_pod=$(kubectl -n rook-ceph get pod -l app=rook-ceph-tools -o name)
					kubectl -n rook-ceph exec $tools_pod -- ceph dashboard set-grafana-api-url http://grafana.monitoring.svc.kube.skaia:3000
					"""]
			}]
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
	resources: {
		crashcollector: {
			requests: cpu: "1m"
			requests: memory: "8Mi"
		}
		mgr: {
			requests: cpu: "50m"
			requests: memory: "500Mi"
		}
		"mgr-sidecar": {
			requests: cpu: "80m"
			requests: memory: "35Mi"
		}
		mon: {
			requests: cpu: "60m"
			requests: memory: "400Mi"
		}
		osd: {
			requests: cpu: "50m"
			requests: memory: "1Gi"
		}
		prepareosd: {
			requests: cpu: "50m"
			requests: memory: "1Gi"
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

// UID/GID used for files on CephFS filesystems where permissioning doesn't matter.
sharedFilesystemUid: 2000
