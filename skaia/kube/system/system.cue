package system

import (
	"cue.skaia/kube/schema"
	"cue.skaia/kube/system/calico"
	"cue.skaia/kube/system/debug"
	"cue.skaia/kube/system/metricsserver"
	"cue.skaia/kube/system/prometheus"
	"cue.skaia/kube/system/rookceph"
	"cue.skaia/kube/system/theila"
)

resources: schema.resources
resources: calico.resources
resources: debug.resources
resources: metricsserver.resources
resources: prometheus.resources
resources: rookceph.resources
resources: theila.resources
