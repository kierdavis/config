package prometheus

resources: deployments: monitoring: {
	"blackbox-exporter": spec: template: spec: priorityClassName:   "observability"
	"grafana": spec: template: spec: priorityClassName:             "observability"
	"kube-state-metrics": spec: template: spec: priorityClassName:  "observability"
	"prometheus-adapter": spec: template: spec: priorityClassName:  "observability"
	"prometheus-operator": spec: template: spec: priorityClassName: "observability"
}
resources: daemonsets: monitoring: "node-exporter": spec: template: spec: priorityClassName: "observability"

resources: services: monitoring: "prometheus-k8s-ui": spec: {
	ports: [{
		name:       "ui"
		port:       80
		targetPort: "web"
	}]
	selector:        resources.services.monitoring."prometheus-k8s".spec.selector
	sessionAffinity: resources.services.monitoring."prometheus-k8s".spec.sessionAffinity
}

resources: services: monitoring: "alertmanager-main-ui": spec: {
	ports: [{
		name:       "ui"
		port:       80
		targetPort: "web"
	}]
	selector:        resources.services.monitoring."alertmanager-main".spec.selector
	sessionAffinity: resources.services.monitoring."alertmanager-main".spec.sessionAffinity
}

resources: services: monitoring: "grafana-ui": spec: {
	ports: [{
		name:       "ui"
		port:       80
		targetPort: "http"
	}]
	selector: resources.services.monitoring.grafana.spec.selector
}

resources: prometheuses: monitoring: k8s: spec: {
	priorityClassName: "observability"
	replicas:          1
	resources: {
		requests: cpu:    "250m"
		requests: memory: "1Gi"
	}
	retentionSize: "15GiB"
	storage: volumeClaimTemplate: spec: {
		storageClassName: "ceph-blk-gp0"
		accessModes: ["ReadWriteOnce"]
		resources: requests: storage: "16Gi"
	}
}

resources: alertmanagers: monitoring: main: spec: {
	priorityClassName: "observability"
	replicas:          1
	resources: {
		requests: cpu:    "1m"
		requests: memory: "25Mi"
	}
	storage: volumeClaimTemplate: spec: {
		storageClassName: "ceph-blk-gp0"
		accessModes: ["ReadWriteOnce"]
		resources: requests: storage: "2Gi"
	}
}

resources: deployments: monitoring: "prometheus-adapter": spec: replicas: 1

// By default, prometheus is only allowed to auto-discover endpoints in a few namespaces (default, kube-system, monitoring).
// Allow any namespace.
resources: clusterroles: "": "prometheus-k8s-any-ns": rules: [
	{
		apiGroups: [""]
		resources: ["endpoints", "pods", "services"]
		verbs: ["get", "list", "watch"]
	},
	{
		apiGroups: ["extensions"]
		resources: ["ingresses"]
		verbs: ["get", "list", "watch"]
	},
	{
		apiGroups: ["networking.k8s.io"]
		resources: ["ingresses"]
		verbs: ["get", "list", "watch"]
	},
]
resources: clusterrolebindings: "": "prometheus-k8s-any-ns": {
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "prometheus-k8s-any-ns"
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      "prometheus-k8s"
		namespace: "monitoring"
	}]
}

resources: prometheusrules: monitoring: "my-rules": spec: groups: [{
	name: "scheduling-sanity"
	rules: [{
		alert: "ContainerWithoutCPURequest"
		expr: """
			kube_pod_container_info
			unless on(namespace, pod, container) kube_pod_container_resource_requests{resource=\"cpu\"}
			"""
		labels: severity:         "warning"
		annotations: summary:     "Container does not define a CPU resource request."
		annotations: description: "Container {{$labels.container}} in pod {{$labels.pod}} in namespace {{$labels.namespace}} does not define a CPU resource request, so it may be scheduled onto a node with insufficient available CPU time."
	}, {
		alert: "ContainerWithoutMemoryRequest"
		expr: """
			kube_pod_container_info
			unless on(namespace, pod, container) kube_pod_container_resource_requests{resource=\"memory\"}
			"""
		labels: severity:         "warning"
		annotations: summary:     "Container does not define a memory resource request."
		annotations: description: "Container {{$labels.container}} in pod {{$labels.pod}} in namespace {{$labels.namespace}} does not define a memory resource request, so it may be scheduled onto a node with insufficient available memory."
	}, {
		alert: "ContainerWithResourceLimit"
		expr: """
			kube_pod_container_resource_limits
			# Talos manages a memory limit on the coredns pods; it can't be removed without patching & recompiling Talos.
			unless kube_pod_container_resource_limits{namespace=\"kube-system\", container=\"coredns\"}
			"""
		labels: severity:         "warning"
		annotations: summary:     "Container defines a resource limit."
		annotations: description: "Container {{$labels.container}} in pod {{$labels.pod}} in namespace {{$labels.namespace}} defines a resource limit. Assuming all containers define appropriate resource requests, there's generally no reason to use limits since they introduce pointless CPU throttling or OOM killing. The kernel will still throttle/kill offending processes when it's short on resources."
	}]
}]
