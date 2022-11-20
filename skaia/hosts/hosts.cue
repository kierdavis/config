package hosts

#schema: {
	isKubeMaster: bool | *false
	isKubeNode:   isKubeMaster
	addresses: {
		prospitHosts: string | *null
		kubeHosts:    string | *null
	}
	bgpASNumber: >=64512 & <=65534
}

hosts: [string]: #schema

hosts: {
	prospit: {
		addresses: {
			prospitHosts: "10.88.1.1"
		}
		bgpASNumber: 64600
	}
	vantas: {
		isKubeMaster: true
		addresses: {
			prospitHosts: "10.88.1.2"
			kubeHosts:    prospitHosts
		}
		bgpASNumber: 64601
	}
	pyrope: {
		isKubeMaster: true
		addresses: {
			prospitHosts: "10.88.1.3"
			kubeHosts:    prospitHosts
		}
		bgpASNumber: 64602
	}
	serket: {
		isKubeMaster: true
		addresses: {
			prospitHosts: "10.88.1.4"
			kubeHosts:    prospitHosts
		}
		bgpASNumber: 64603
	}
	coloris: {
		bgpASNumber: 64604
	}
}
