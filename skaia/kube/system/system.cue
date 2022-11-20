package system

import (
	"cue.skaia/kube/schema"
	"cue.skaia/kube/system/calico"
	"cue.skaia/kube/system/debug"
	"cue.skaia/kube/system/rookceph"
	"cue.skaia/kube/system/theila"
)

resources: schema.resources
resources: calico.resources
resources: debug.resources
resources: rookceph.resources
resources: theila.resources
