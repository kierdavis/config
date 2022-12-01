package prometheus

resources: deployments: monitoring: {
	"blackbox-exporter": spec: template: spec: priorityClassName: "observability"
	"grafana": spec: template: spec: priorityClassName: "observability"
	"kube-state-metrics": spec: template: spec: priorityClassName: "observability"
	"prometheus-adapter": spec: template: spec: priorityClassName: "observability"
	"prometheus-operator": spec: template: spec: priorityClassName: "observability"
}
resources: daemonsets: monitoring: "node-exporter": spec: template: spec: priorityClassName: "observability"

resources: services: monitoring: grafana: spec: ports: [{ port: 80 }, ...]
resources: networkpolicies: monitoring: grafana: spec: ingress: [{ ports: [{ port: 80 }, ...] }, ...]

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
