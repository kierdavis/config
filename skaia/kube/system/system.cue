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

resources: namespaces: "": "talos-system": {}

resources: priorityclasses: "": "observability": value: 1000
resources: priorityclasses: "": "personal-critical": value: 2000
