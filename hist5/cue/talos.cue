package hist5

import (
	"net"
)

machines: [_]: {
	name: string
	addresses: {
		gcpMachines: (string & net.IP) | *null
		wireguard: string & net.IP
	}
	wireguardKey: {
		public: string
		private: string
	}
	isKubeMaster: bool
	talos: {
		version: "v1alpha1"
		debug: false
		persist: true
		machine: {
			type: "controlplane"
			token: string
			ca: crt: string
			ca: key: string
			certSANs: []
			kubelet: nodeIP: validSubnets: [networks.wireguard.cidr]
			features: rbac: true
			features: kubernetesTalosAPIAccess: {
				enabled: true
				allowedRoles: ["os:reader"]
				allowedKubernetesNamespaces: ["system"]
			}
			network: {
				hostname: name
				interfaces: [{
					interface: "wg-hist5"
					"addresses": ["\(addresses.wireguard)/\(networks.wireguard.prefixLength)"]
					mtu: networks.wireguard.mtu
					dhcp: false
					wireguard: {
						privateKey: wireguardKey.private
						listenPort: networks.wireguard.listenPort
						peers: [
							for peer in machines
							if peer.name != name
							{
								publicKey: peer.wireguardKey.public
								persistentKeepaliveInterval: "25s"
								allowedIPs: ["\(peer.addresses.wireguard)/32"]
								if addresses.gcpMachines != null && peer.addresses.gcpMachines != null
								{ endpoint: "\(peer.addresses.gcpMachines):\(networks.wireguard.listenPort)" }
								if !(addresses.gcpMachines != null && peer.addresses.gcpMachines != null) && peer.addresses.internet != null
								{ endpoint: "\(peer.addresses.internet):\(networks.wireguard.listenPort)" }
							}
						]
					}
				}]
				extraHostEntries: [
					for machine in machines
					if machine.isKubeMaster
					{
						ip: machine.addresses.wireguard
						aliases: ["kubeapi.hist5"]
					}
				]
			}
		}
		cluster: {
			id: string
			secret: string
			controlPlane: endpoint: "https://kubeapi.hist5:6443"
			clusterName: "hist5"
			network: {
				cni: name: "none"
				dnsDomain: "kube.hist5"
				podSubnets: [networks.pods.cidr]
				serviceSubnets: [networks.services.cidr]
			}
			token: string
			aescbcEncryptionSecret: string
			ca:	crt: string
			ca: key: string
			aggregatorCA: crt: string
			aggregatorCA: key: string
			serviceAccount:	key: string
			apiServer: certSANs: [
				"kubeapi.hist5",
				for machine in machines
				if machine.isKubeMaster
				{
					machine.addresses.wireguard
				}
			]
			apiServer: disablePodSecurityPolicy: true
			discovery: enabled: false
			etcd: ca: crt: string
			etcd: ca: key: string
			etcd: advertisedSubnets: [networks.wireguard.cidr]
			etcd: listenSubnets: [networks.wireguard.cidr]
			coreDNS: disabled: false
			allowSchedulingOnControlPlanes: true
		}
	}
}

talosconfig: {
	context: "hist5"
	contexts: hist5: {
		endpoints: [
			for machine in machines
			if machine.isKubeNode
			{
				machine.addresses.wireguard
			}
		]
		nodes: [endpoints[0]]
		ca: string
		crt: string
		key: string
	}
}

kubeconfig: {
	apiVersion: "v1"
	kind: "Config"
	clusters: [{
		name: "hist5"
		cluster: {
			"certificate-authority-data": machines.talosgcp1.talos.cluster.ca.crt
			// "server": "https://\(machines.talosgcp1.addresses.wireguard):6443"
			"server": "https://10.181.8.1"
		}
	}]
	users: [{
		name: "admin@hist5"
		user: {
			"client-certificate-data": string
			"client-key-data": string
		}
	}]
	contexts: [{
		name: "admin@hist5"
		context: {
			cluster: "hist5"
			user: "admin@hist5"
		}
	}]
	"current-context": "admin@hist5"
}
