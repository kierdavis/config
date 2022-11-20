package prometheus

import (
	"cue.skaia/kube/schema"
)

resources: schema.resources

resources: prometheuses: monitoring: k8s: spec: {
	replicas: 1
	retentionSize: "3.8GiB"
	storage: volumeClaimTemplate: spec: {
		storageClassName: "ceph-blk-replicated"
		accessModes: ["ReadWriteOnce"]
		resources: requests: storage: "4Gi"
	}
}
