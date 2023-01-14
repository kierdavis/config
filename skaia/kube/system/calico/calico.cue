package calico

import (
	"cue.skaia/networks"
	"cue.skaia/hosts"
)

resources: deployments: "kube-system": "calico-kube-controllers": spec: template: spec: containers: [{
	name: "calico-kube-controllers"  // assert we're operating on the expected element of the list
	resources: {
		requests: cpu: "5m"
		requests: memory: "30Mi"
		limits: requests
	}
}, ...]

resources: daemonsets: "kube-system": "calico-node": spec: template: spec: containers: [{
	name: "calico-node"  // assert we're operating on the expected element of the list
	env: [{
		name: "CALICO_IPV4POOL_CIDR"  // assert we're operating on the expected element of the list
		value: networks.networks.pods.cidr
	}, ...]
	resources: {
		requests: cpu: "75m"
		requests: memory: "180Mi"
		limits: requests
	}
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

resources: bgppeers: "": "coloris": spec: {
	peerIP:   hosts.hosts.coloris.addresses.bgp
	asNumber: hosts.hosts.coloris.bgpASNumber
}
