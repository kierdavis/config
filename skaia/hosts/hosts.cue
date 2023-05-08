package hosts

#schema: {
	addresses: [string]: string | *null
	bgpASNumber: >=64512 & <=65534
	isKubeMaster: bool | *false
	isKubeNode:   isKubeMaster
	nodeLabels: [string]: string
}

hosts: [string]: #schema

hosts: {
	megido: {
		addresses: {
			internet: "151.236.219.214"
			linodeHosts: "10.88.1.9"
			kubeHosts: linodeHosts
			talosDeploy: linodeHosts
			talosInitialDeploy: internet
			bgp: linodeHosts
		}
		bgpASNumber: 64605
		isKubeMaster: true
		nodeLabels: {
			"topology.rook.io/chassis": "chassis-megido"
			"topology.rook.io/zone": "zone-linode-london"
			"topology.kubernetes.io/zone": "zone-linode-london"
		}
	}
	captor: {
		addresses: {
			internet: "172.105.133.104"
			linodeHosts: "10.88.1.10"
			kubeHosts: linodeHosts
			talosDeploy: linodeHosts
			talosInitialDeploy: internet
			bgp: linodeHosts
		}
		bgpASNumber: 64606
		isKubeMaster: true
		nodeLabels: {
			"topology.rook.io/chassis": "chassis-captor"
			"topology.rook.io/zone": "zone-linode-london"
			"topology.kubernetes.io/zone": "zone-linode-london"
		}
	}
	maryam: {
		addresses: {
			lan: "192.168.178.2"
			kubeHosts: "10.88.1.1"
			talosDeploy: kubeHosts
			talosInitialDeploy: lan
			bgp: kubeHosts
		}
		bgpASNumber: 64607
		isKubeMaster: true
		nodeLabels: {
			"topology.rook.io/chassis": "chassis-maryam"
			"topology.rook.io/zone": "zone-advent-way"
			"topology.kubernetes.io/zone": "zone-advent-way"
		}
	}
	coloris: {
		addresses: {
			lan: "192.168.178.4"
			peerHosts: "10.88.3.1"
			bgp: peerHosts
		}
		bgpASNumber: 64604
	}
}
