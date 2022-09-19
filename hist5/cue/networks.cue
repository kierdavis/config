package hist5

import (
	"net"
)

networks: {
	[string]: {
		baseAddress: string & net.IP
		prefixLength: uint
		cidr: "\(baseAddress)/\(prefixLength)" // net.IPCIDR only available in cue >= 0.4.3
	}

	gcpMachines: {
		baseAddress: "10.181.1.0"
		prefixLength: 24
		mtu: 1460
	}

	wireguard: {
		baseAddress: "10.181.2.0"
		prefixLength: 24
		mtu: gcpMachines.mtu - 80
		listenPort: 19908
	}

	services: {
		baseAddress: "10.181.8.0"
		prefixLength: 21
	}

	pods: {
		baseAddress: "10.181.16.0"
		prefixLength: 20
	}
}
