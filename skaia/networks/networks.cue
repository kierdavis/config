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

networks: linodeHosts: {
	firstAddress: "10.88.1.8"
	prefixLength: 29
}

networks: peerHosts: {
	firstAddress: "10.88.3.0"
	prefixLength: 24
}

networks: pods: {
	firstAddress: "10.88.128.0"
	prefixLength: 18
}

networks: services: {
	firstAddress: "10.88.192.0"
	prefixLength: 18
}

wireguard: colorisAndMegido: listenPort: 5350
wireguard: captorAndColoris: listenPort: 5351
wireguard: maryamAndMegido: listenPort: 5352
wireguard: captorAndMaryam: listenPort: 5353
wireguard: megidoAndSaelli: listenPort: 5354
wireguard: captorAndSaelli: listenPort: 5355
