package system

import (
	"cue.skaia/hosts"
	"cue.skaia/kube/schema"
	"cue.skaia/kube/system/calico"
	"cue.skaia/kube/system/debug"
	"cue.skaia/kube/system/prometheus"
	"cue.skaia/kube/system/rookceph"
	"cue.skaia/kube/system/theila"
)

resources: schema.resources
resources: calico.resources
resources: debug.resources
resources: prometheus.resources
resources: rookceph.resources
resources: theila.resources

resources: nodes: "": {
	for hostName, host in hosts.hosts
	if host.isKubeNode
	{
		"\(hostName)": metadata: labels: host.kubeNodeLabels
	}
}
