package hist5

import (
	"net"
)

machines: [Name=string]: {
	name: Name
	addresses: {
		gcpMachines: (string & net.IP) | *null
		wireguard: string & net.IP
		internet: (string & net.IP) | *null
	}
	gcpZone: string | *null
	isKubeMaster: bool | *false
	isKubeWorker: bool | *false
	isKubeNode: isKubeMaster || isKubeWorker
}

machines: "talosgcp1": {
	addresses: wireguard: "10.181.2.1"
	gcpZone: "\(gcpRegion)-b"
	isKubeMaster: true
}

machines: "talosgcp2": {
	addresses: wireguard: "10.181.2.2"
	gcpZone: "\(gcpRegion)-c"
	isKubeMaster: true
}

machines: "talosgcp3": {
	addresses: wireguard: "10.181.2.3"
	gcpZone: "\(gcpRegion)-d"
	isKubeMaster: true
}

machines: "coloris": {
	addresses: wireguard: "10.181.2.254"
}

machines: "saelli": {
	addresses: wireguard: "10.181.2.253"
}

machines: "fingerbib": {
	addresses: wireguard: "10.181.2.252"
}
