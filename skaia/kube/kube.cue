package kube

import (
	"cue.skaia/kube/schema"
	"cue.skaia/kube/personal"
	"cue.skaia/kube/system"
)

resources: schema.resources
resources: personal.resources
resources: system.resources
