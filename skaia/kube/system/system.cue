package system

import (
	"cue.skaia/kube/system/calico"
	"cue.skaia/kube/system/debug"
	"cue.skaia/kube/system/ingressnginx"
	"cue.skaia/kube/system/postgresoperator"
	"cue.skaia/kube/system/prometheus"
	"cue.skaia/kube/system/rookceph"
	"cue.skaia/kube/system/stash"
	"cue.skaia/kube/system/theila"
	"cue.skaia/hosts"
)

resources: calico.resources
resources: debug.resources
resources: ingressnginx.resources
resources: postgresoperator.resources
resources: prometheus.resources
resources: rookceph.resources
resources: stash.resources
resources: theila.resources

resources: daemonsets: "kube-system": "kube-proxy": spec: template: spec: containers: [{
	name: "kube-proxy" // assert we're operating on the expected element of the list
	resources: requests: cpu:    "1m"
	resources: requests: memory: "30Mi"
}, ...]

resources: namespaces: "": "talos-system": {}

resources: priorityclasses: "": "best-effort": value:       100
resources: priorityclasses: "": "observability": value:     1000
resources: priorityclasses: "": "personal-critical": value: 2000

resources: nodes: "": {
	for hostName, host in hosts.hosts
	if host.isKubeNode {
		"\(hostName)": metadata: labels: host.nodeLabels
	}
}

resources: daemonsets: "talos-system": "tuning": {
	metadata: labels: app: "tuning"
	spec: {
		updateStrategy: {
			type: "RollingUpdate"
			rollingUpdate: maxUnavailable: "100%"
		}
		selector: matchLabels: app: "tuning"
		template: {
			metadata: labels: app: "tuning"
			spec: {
				hostNetwork: true
				containers: [{
					name: "main"
					image: "busybox"
					command: ["sh", "-c", "for i in /sys/class/block/sd*/queue/scheduler; do echo $i; echo none > $i; done; exec sleep infinity"]
					securityContext: privileged: true
				}]
			}
		}
	}
}
