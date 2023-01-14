package hosts

#schema: {
	addresses: [string]: string | *null
	bgpASNumber: >=64512 & <=65534
	isKubeMaster: bool | *false
	isKubeNode:   isKubeMaster
	cephCrushLabels: [string]: string
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
		cephCrushLabels: {
			chassis: "chassis-megido"
			zone: "zone-linode-london"
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
		cephCrushLabels: {
			chassis: "chassis-captor"
			zone: "zone-linode-london"
		}
	}
	coloris: {
		addresses: {
			peerHosts: "10.88.3.1"
			adventWay: "192.168.178.4"
			bgp: peerHosts
		}
		bgpASNumber: 64604
	}
}
