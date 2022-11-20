package calico

import (
	"cue.skaia/kube/schema"
	"cue.skaia/networks"
	"cue.skaia/hosts"
)

resources: schema.resources

podNetworkCidr: networks.networks.pods.cidr

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
