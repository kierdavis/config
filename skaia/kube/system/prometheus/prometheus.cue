package prometheus

import (
	"cue.skaia/hosts"
	"cue.skaia/networks"
)

resources: deployments: monitoring: {
	"blackbox-exporter": spec: template: spec: priorityClassName: "observability"
	"grafana": spec: template: spec: priorityClassName: "observability"
	"kube-state-metrics": spec: template: spec: priorityClassName: "observability"
	"prometheus-adapter": spec: template: spec: priorityClassName: "observability"
	"prometheus-operator": spec: template: spec: priorityClassName: "observability"
}
resources: daemonsets: monitoring: "node-exporter": spec: template: spec: priorityClassName: "observability"

resources: services: monitoring: "alertmanager-main": spec: ports: [{ port: 80 }, ...]
resources: networkpolicies: monitoring: "alertmanager-main": spec: ingress: [{ ports: [{ port: 80 }, ...] }, ...]

resources: services: monitoring: grafana: spec: ports: [{ port: 80 }, ...]
resources: networkpolicies: monitoring: grafana: spec: ingress: [{ ports: [{ port: 80 }, ...] }, ...]

resources: networkpolicies: monitoring: "prometheus-from-workstation": spec: {
	podSelector: resources.networkpolicies.monitoring["prometheus-k8s"].spec.podSelector
	policyTypes: ["Ingress"]
	ingress: [{
		from: [
			{ ipBlock: cidr: networks.networks.peerHosts.cidr },
			{ ipBlock: cidr: "\(hosts.hosts.coloris.addresses.lan)/32" },
		]
		ports: [{ protocol: "TCP", port: 9090 }]
	}]
}

resources: networkpolicies: monitoring: "alertmanager-from-workstation": spec: {
	podSelector: resources.networkpolicies.monitoring["alertmanager-main"].spec.podSelector
	policyTypes: ["Ingress"]
	ingress: [{
		from: [
			{ ipBlock: cidr: networks.networks.peerHosts.cidr },
			{ ipBlock: cidr: "\(hosts.hosts.coloris.addresses.lan)/32" },
		]
		ports: [{ protocol: "TCP", port: 9093 }]
	}]
}

resources: networkpolicies: monitoring: "grafana-from-workstation": spec: {
	podSelector: resources.networkpolicies.monitoring.grafana.spec.podSelector
	policyTypes: ["Ingress"]
	ingress: [{
		from: [
			{ ipBlock: cidr: networks.networks.peerHosts.cidr },
			{ ipBlock: cidr: "\(hosts.hosts.coloris.addresses.lan)/32" },
		]
		ports: [{ protocol: "TCP", port: 3000 }]
	}]
}

resources: prometheuses: monitoring: k8s: spec: {
	priorityClassName: "observability"
	replicas: 1
	resources: {
		requests: cpu: "250m"
		requests: memory: "1.2Gi"
		limits: memory: "1.8Gi"
	}
	retentionSize: "3GiB"
	storage: volumeClaimTemplate: spec: {
		storageClassName: "ceph-blk-replicated"
		accessModes: ["ReadWriteOnce"]
		resources: requests: storage: "4Gi"
	}
}

resources: alertmanagers: monitoring: main: spec: {
	priorityClassName: "observability"
	replicas: 1
}

resources: deployments: monitoring: "prometheus-adapter": spec: replicas: 1
