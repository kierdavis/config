package hosts

#schema: {
	addresses: {
		prospitHosts: string | *null
		kubeHosts:    string | *null
	}
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
	vantas: {
		addresses: {
			prospitHosts: "10.88.1.2"
			kubeHosts:    prospitHosts
		}
		bgpASNumber: 64601
		isKubeMaster: true
		cephCrushLabels: {
			chassis: "prospit"
			zone: "advent-way"
		}
	}
	pyrope: {
		addresses: {
			prospitHosts: "10.88.1.3"
			kubeHosts:    prospitHosts
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
		}
		bgpASNumber: 64603
		isKubeMaster: true
		cephCrushLabels: {
			chassis: "prospit"
			zone: "advent-way"
		}
	}
	coloris: {
		bgpASNumber: 64604
	}
}
