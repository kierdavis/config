package prometheus

import (
	"cue.skaia/kube/schema"
)

resources: schema.resources

resources: deployments: monitoring: {
	"blackbox-exporter": spec: template: spec: priorityClassName: "observability"
	"grafana": spec: template: spec: priorityClassName: "observability"
	"kube-state-metrics": spec: template: spec: priorityClassName: "observability"
	"prometheus-adapter": spec: template: spec: priorityClassName: "observability"
	"prometheus-operator": spec: template: spec: priorityClassName: "observability"
}
resources: daemonsets: monitoring: "node-exporter": spec: template: spec: priorityClassName: "observability"

resources: prometheuses: monitoring: k8s: spec: {
	priorityClassName: "observability"
	replicas: 1
	retentionSize: "3.8GiB"
	storage: volumeClaimTemplate: spec: {
		storageClassName: "ceph-blk-replicated"
		accessModes: ["ReadWriteOnce"]
		resources: requests: storage: "4Gi"
	}
}
