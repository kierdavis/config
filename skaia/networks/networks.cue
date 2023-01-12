package networks

#schema: {
	firstAddress: string
	prefixLength: uint8
	cidr:         "\(firstAddress)/\(prefixLength)"
	listenPort: (>=14980 & <14990) | *null
}

networks: [string]: #schema

networks: kubeHosts: {
	firstAddress: "10.88.1.0"
	prefixLength: 24
}

networks: prospitHosts: {
	firstAddress: "10.88.1.0"
	prefixLength: 29
}

networks: linodeHosts: {
	firstAddress: "10.88.1.8"
	prefixLength: 29
}

networks: wgMegidoProspit: {
	firstAddress: "10.88.2.0"
	prefixLength: 30
	listenPort: 14980
}

networks: wgCaptorProspit: {
	firstAddress: "10.88.2.4"
	prefixLength: 30
	listenPort: 14981
}

networks: pods: {
	firstAddress: "10.88.128.0"
	prefixLength: 18
}

networks: services: {
	firstAddress: "10.88.192.0"
	prefixLength: 18
}
