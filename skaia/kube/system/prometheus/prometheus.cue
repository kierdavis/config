package prometheus

resources: deployments: monitoring: {
	"blackbox-exporter": spec: template: spec: priorityClassName: "observability"
	"grafana": spec: template: spec: priorityClassName: "observability"
	"kube-state-metrics": spec: template: spec: priorityClassName: "observability"
	"prometheus-adapter": spec: template: spec: priorityClassName: "observability"
	"prometheus-operator": spec: template: spec: priorityClassName: "observability"
}
resources: daemonsets: monitoring: "node-exporter": spec: template: spec: priorityClassName: "observability"

resources: services: monitoring: "prometheus-k8s-ui": spec: {
	ports: [{
		name: "ui"
		port: 80
		targetPort: "web"
	}]
	selector: resources.services.monitoring."prometheus-k8s".spec.selector
	sessionAffinity: resources.services.monitoring."prometheus-k8s".spec.sessionAffinity
}

resources: services: monitoring: "alertmanager-main-ui": spec: {
	ports: [{
		name: "ui"
		port: 80
		targetPort: "web"
	}]
	selector: resources.services.monitoring."alertmanager-main".spec.selector
	sessionAffinity: resources.services.monitoring."alertmanager-main".spec.sessionAffinity
}

resources: services: monitoring: "grafana-ui": spec: {
	ports: [{
		name: "ui"
		port: 80
		targetPort: "http"
	}]
	selector: resources.services.monitoring.grafana.spec.selector
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
	storage: volumeClaimTemplate: spec: {
		storageClassName: "ceph-blk-replicated"
		accessModes: ["ReadWriteOnce"]
		resources: requests: storage: "2Gi"
	}
}

resources: deployments: monitoring: "prometheus-adapter": spec: replicas: 1

resources: prometheusrules: monitoring: "my-rules": spec: groups: [{
	name: "scheduling-sanity",
	rules: [{
		alert: "ContainerWithoutCPURequest"
		expr: "kube_pod_container_info unless on(namespace, pod, container) kube_pod_container_resource_requests{resource=\"cpu\"}"
		labels: severity: "warning"
		annotations: summary: "Container does not define a CPU resource request."
		annotations: description: "Container {{$labels.container}} in pod {{$labels.pod}} in namespace {{$labels.namespace}} does not define a CPU resource request, so it may be scheduled onto a node with insufficient available CPU time."
	}, {
		alert: "ContainerWithoutMemoryRequest"
		expr: "kube_pod_container_info unless on(namespace, pod, container) kube_pod_container_resource_requests{resource=\"memory\"}"
		labels: severity: "warning"
		annotations: summary: "Container does not define a memory resource request."
		annotations: description: "Container {{$labels.container}} in pod {{$labels.pod}} in namespace {{$labels.namespace}} does not define a memory resource request, so it may be scheduled onto a node with insufficient available memory."
	}, {
		alert: "ContainerWithCPULimit"
		expr: "kube_pod_container_info and on(namespace, pod, container) kube_pod_container_resource_limits{resource=\"cpu\"}"
		labels: severity: "warning"
		annotations: summary: "Container defines a CPU resource limit."
		annotations: description: "Container {{$labels.container}} in pod {{$labels.pod}} in namespace {{$labels.namespace}} defines a CPU resource limit. Assuming all containers define a suitable CPU request, there's generally no reason to use CPU limits since they introduce pointless throttling."
	}]
}]
