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
		}
		bgpASNumber: 64600
	}
	pyrope: {
		addresses: {
			prospitHosts: "10.88.1.3"
			kubeHosts:    prospitHosts
			talosDeploy: prospitHosts
			talosInitialDeploy: prospitHosts
			wgMegidoPyrope: "10.88.2.2"
			wgCaptorPyrope: "10.88.2.10"
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
			wgMegidoSerket: "10.88.2.6"
			wgCaptorSerket: "10.88.2.14"
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
			wgMegidoPyrope: "10.88.2.1"
			wgMegidoSerket: "10.88.2.5"
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
			wgCaptorPyrope: "10.88.2.9"
			wgCaptorSerket: "10.88.2.13"
		}
		bgpASNumber: 64606
		isKubeMaster: true
		cephCrushLabels: {
			chassis: "chassis-captor"
			zone: "zone-linode-london"
		}
	}
	coloris: {
		bgpASNumber: 64604
	}
}
