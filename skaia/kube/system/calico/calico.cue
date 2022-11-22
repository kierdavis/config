package calico

import (
	"cue.skaia/networks"
	"cue.skaia/hosts"
)

resources: daemonsets: "kube-system": "calico-node": spec: template: spec: containers: [{
	name: "calico-node"  // assert we're operating on the expected element of the list
	env: [{
		name: "CALICO_IPV4POOL_CIDR"  // assert we're operating on the expected element of the list
		value: networks.networks.pods.cidr
	}, ...]
}, ...]

resources: nodes: "": {
	for hostName, host in hosts.hosts
	if host.isKubeNode {
		"\(hostName)": metadata: annotations: "projectcalico.org/ASNumber": "\(host.bgpASNumber)"
	}
}

resources: caliconodestatuses: "": {
	for hostName, host in hosts.hosts
	if host.isKubeNode {
		"\(hostName)": spec: {
			node: hostName
			classes: ["Agent", "BGP", "Routes"]
			updatePeriodSeconds: 30
		}
	}
}

resources: bgpconfigurations: "": "default": spec: {
	serviceClusterIPs: [{cidr: networks.networks.services.cidr}]
}

resources: bgppeers: "": "prospit": spec: {
	peerIP:   hosts.hosts.prospit.addresses.prospitHosts
	asNumber: hosts.hosts.prospit.bgpASNumber
}
