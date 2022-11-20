package networks

#schema: {
	firstAddress: string
	prefixLength: uint8
	cidr:         "\(firstAddress)/\(prefixLength)"
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

networks: pods: {
	firstAddress: "10.88.128.0"
	prefixLength: 18
}

networks: services: {
	firstAddress: "10.88.192.0"
	prefixLength: 18
}
