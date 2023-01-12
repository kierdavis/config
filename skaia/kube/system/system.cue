package system

import (
	"cue.skaia/kube/system/calico"
	"cue.skaia/kube/system/debug"
	"cue.skaia/kube/system/prometheus"
	"cue.skaia/kube/system/rookceph"
	"cue.skaia/kube/system/stash"
	"cue.skaia/kube/system/theila"
)

resources: calico.resources
resources: debug.resources
resources: prometheus.resources
resources: rookceph.resources
resources: stash.resources
resources: theila.resources

resources: daemonsets: "kube-system": "kube-proxy": spec: template: spec: containers: [{
	name: "kube-proxy"  // assert we're operating on the expected element of the list
	resources: requests: cpu: "1m"
	resources: requests: memory: "30Mi"
	resources: limits: memory: "45Mi"
}, ...]

resources: namespaces: "": "talos-system": {}

resources: priorityclasses: "": "best-effort": value: 100
resources: priorityclasses: "": "observability": value: 1000
resources: priorityclasses: "": "personal-critical": value: 2000
