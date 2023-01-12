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
	prospit: {
		addresses: {
			prospitHosts: "10.88.1.1"
			wgMegidoProspit: "10.88.2.2"
			wgCaptorProspit: "10.88.2.6"
		}
		bgpASNumber: 64600
	}
	pyrope: {
		addresses: {
			prospitHosts: "10.88.1.3"
			kubeHosts:    prospitHosts
			talosDeploy: prospitHosts
			talosInitialDeploy: prospitHosts
		}
		bgpASNumber: 64602
		isKubeMaster: true
		cephCrushLabels: {
			chassis: "prospit"
			zone: "advent-way"
		}
	}
	serket: {
		addresses: {
			prospitHosts: "10.88.1.4"
			kubeHosts:    prospitHosts
			talosDeploy: prospitHosts
			talosInitialDeploy: prospitHosts
		}
		bgpASNumber: 64603
		isKubeMaster: true
		cephCrushLabels: {
			chassis: "prospit"
			zone: "advent-way"
		}
	}
	megido: {
		addresses: {
			internet: "151.236.219.214"
			linodeHosts: "10.88.1.9"
			kubeHosts: linodeHosts
			talosDeploy: linodeHosts
			talosInitialDeploy: internet
			wgMegidoProspit: "10.88.2.1"
		}
		bgpASNumber: 64605
		isKubeMaster: true
		cephCrushLabels: {
			chassis: "megido"
			zone: "linode-london"
		}
	}
	captor: {
		addresses: {
			internet: "172.105.133.104"
			linodeHosts: "10.88.1.10"
			kubeHosts: linodeHosts
			talosDeploy: linodeHosts
			talosInitialDeploy: internet
			wgCaptorProspit: "10.88.2.5"
		}
		bgpASNumber: 64606
		isKubeMaster: true
		cephCrushLabels: {
			chassis: "captor"
			zone: "linode-london"
		}
	}
	coloris: {
		bgpASNumber: 64604
	}
}
