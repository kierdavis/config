package talos

import (
	"cue.skaia/hosts"
	"cue.skaia/networks"
	"secret.cue.skaia:secret"
)

#networkInterfaces: {
	pyrope: [
		{
			deviceSelector: driver: "virtio_net"
			dhcp: true
		},
		{
			interface: "wg-megido"
			addresses: ["\(hosts.hosts.pyrope.addresses.wgMegidoPyrope)/\(networks.networks.wgMegidoPyrope.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.pyrope.facing.megido.private
				listenPort: networks.networks.wgMegidoPyrope.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.megido.facing.pyrope.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
					endpoint: "\(hosts.hosts.megido.addresses.internet):\(networks.networks.wgMegidoPyrope.listenPort)"
				}]
			}
			routes: [
				{
					network: "\(hosts.hosts.megido.addresses.kubeHosts)/32"
					gateway: hosts.hosts.megido.addresses.wgMegidoPyrope
				},
			]
		},
		{
			interface: "wg-captor"
			addresses: ["\(hosts.hosts.pyrope.addresses.wgCaptorPyrope)/\(networks.networks.wgCaptorPyrope.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.pyrope.facing.captor.private
				listenPort: networks.networks.wgCaptorPyrope.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.captor.facing.pyrope.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
					endpoint: "\(hosts.hosts.captor.addresses.internet):\(networks.networks.wgCaptorPyrope.listenPort)"
				}]
			}
			routes: [
				{
					network: "\(hosts.hosts.captor.addresses.kubeHosts)/32"
					gateway: hosts.hosts.captor.addresses.wgCaptorPyrope
				},
			]
		},
	]
	serket: [
		{
			deviceSelector: driver: "virtio_net"
			dhcp: true
		},
		{
			interface: "wg-megido"
			addresses: ["\(hosts.hosts.serket.addresses.wgMegidoSerket)/\(networks.networks.wgMegidoSerket.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.serket.facing.megido.private
				listenPort: networks.networks.wgMegidoSerket.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.megido.facing.serket.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
					endpoint: "\(hosts.hosts.megido.addresses.internet):\(networks.networks.wgMegidoSerket.listenPort)"
				}]
			}
			routes: [
				{
					network: "\(hosts.hosts.megido.addresses.kubeHosts)/32"
					gateway: hosts.hosts.megido.addresses.wgMegidoSerket
				},
			]
		},
		{
			interface: "wg-captor"
			addresses: ["\(hosts.hosts.serket.addresses.wgCaptorSerket)/\(networks.networks.wgCaptorSerket.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.serket.facing.captor.private
				listenPort: networks.networks.wgCaptorSerket.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.captor.facing.serket.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
					endpoint: "\(hosts.hosts.captor.addresses.internet):\(networks.networks.wgCaptorSerket.listenPort)"
				}]
			}
			routes: [
				{
					network: "\(hosts.hosts.captor.addresses.kubeHosts)/32"
					gateway: hosts.hosts.captor.addresses.wgCaptorSerket
				},
			]
		},
	]
	megido: [
		{
			interface: "eth0"
			dhcp: true
		},
		{
			interface: "eth1"
			dhcp: false
			addresses: ["\(hosts.hosts.megido.addresses.linodeHosts)/\(networks.networks.linodeHosts.prefixLength)"]
		},
		{
			interface: "wg-pyrope"
			addresses: ["\(hosts.hosts.megido.addresses.wgMegidoPyrope)/\(networks.networks.wgMegidoPyrope.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.megido.facing.pyrope.private
				listenPort: networks.networks.wgMegidoPyrope.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.pyrope.facing.megido.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
				}]
			}
			routes: [
				{
					network: "\(hosts.hosts.pyrope.addresses.kubeHosts)/32"
					gateway: hosts.hosts.pyrope.addresses.wgMegidoPyrope
				},
			]
		},
		{
			interface: "wg-serket"
			addresses: ["\(hosts.hosts.megido.addresses.wgMegidoSerket)/\(networks.networks.wgMegidoSerket.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.megido.facing.serket.private
				listenPort: networks.networks.wgMegidoSerket.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.serket.facing.megido.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
				}]
			}
			routes: [
				{
					network: "\(hosts.hosts.serket.addresses.kubeHosts)/32"
					gateway: hosts.hosts.serket.addresses.wgMegidoSerket
				},
			]
		},
	]
	captor: [
		{
			interface: "eth0"
			dhcp: true
		},
		{
			interface: "eth1"
			dhcp: false
			addresses: ["\(hosts.hosts.captor.addresses.linodeHosts)/\(networks.networks.linodeHosts.prefixLength)"]
		},
		{
			interface: "wg-pyrope"
			addresses: ["\(hosts.hosts.captor.addresses.wgCaptorPyrope)/\(networks.networks.wgCaptorPyrope.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.captor.facing.pyrope.private
				listenPort: networks.networks.wgCaptorPyrope.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.pyrope.facing.captor.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
				}]
			}
			routes: [
				{
					network: "\(hosts.hosts.pyrope.addresses.kubeHosts)/32"
					gateway: hosts.hosts.pyrope.addresses.wgCaptorPyrope
				},
			]
		},
		{
			interface: "wg-serket"
			addresses: ["\(hosts.hosts.captor.addresses.wgCaptorSerket)/\(networks.networks.wgCaptorSerket.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.captor.facing.serket.private
				listenPort: networks.networks.wgCaptorSerket.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.serket.facing.captor.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
				}]
			}
			routes: [
				{
					network: "\(hosts.hosts.serket.addresses.kubeHosts)/32"
					gateway: hosts.hosts.serket.addresses.wgCaptorSerket
				},
			]
		},
	]
}

#common: secret.talos & {
	version: "v1alpha1"
	debug:   false
	persist: true
	machine: {
		type:  "controlplane"
		token: string
		ca: crt: string
		ca: key: string
		certSANs: []
		kubelet: nodeIP: validSubnets: [networks.networks.kubeHosts.cidr]
		features: rbac: true
		features: kubernetesTalosAPIAccess: {
			enabled: true
			allowedRoles: ["os:admin"]
			allowedKubernetesNamespaces: ["talos-system"]
		}
		install: {
			disk:       "/dev/sda"
			bootloader: true
		}
		network: {
			hostname: string
			interfaces: #networkInterfaces[hostname]
			nameservers: ["1.1.1.1", "1.0.0.1"]
			extraHostEntries: [
				for host in hosts.hosts
				if host.isKubeMaster {
					ip: host.addresses.kubeHosts
					aliases: ["kubeapi.skaia"]
				},
			]
		}
	}
	cluster: {
		id:     string
		secret: string
		controlPlane: endpoint: "https://kubeapi.skaia:6443"
		clusterName: "skaia"
		network: {
			cni: name: "none"
			dnsDomain: "kube.skaia"
			podSubnets: [networks.networks.pods.cidr]
			serviceSubnets: [networks.networks.services.cidr]
		}
		token:                  string
		aescbcEncryptionSecret: string
		ca: crt:             string
		ca: key:             string
		aggregatorCA: crt:   string
		aggregatorCA: key:   string
		serviceAccount: key: string
		apiServer: certSANs: [
			"kubeapi.skaia",
			for host in hosts.hosts
			if host.isKubeMaster {
				host.addresses.kubeHosts
			},
		]
		apiServer: disablePodSecurityPolicy: true
		discovery: enabled:                  false
		etcd: ca: crt: string
		etcd: ca: key: string
		etcd: advertisedSubnets: [networks.networks.kubeHosts.cidr]
		etcd: listenSubnets: [networks.networks.kubeHosts.cidr]
		coreDNS: disabled: false
		allowSchedulingOnControlPlanes: true
	}
}

byHost: {
	for hostName, host in hosts.hosts
	if host.isKubeNode
	{
		"\(hostName)": #common & {
			machine: network: hostname: hostName
		}
	}
}

talosconfig: secret.talosconfig & {
	context: "skaia"
	contexts: skaia: {
		endpoints: [
			for host in hosts.hosts
			if host.isKubeNode {
				host.addresses.talosDeploy
			},
		]
		nodes: endpoints
		ca:    string
		crt:   string
		key:   string
	}
}

kubeconfig: secret.kubeconfig & {
	apiVersion: "v1"
	kind:       "Config"
	clusters: [{
		name: "skaia"
		cluster: {
			"certificate-authority-data": #common.cluster.ca.crt
			"server":                     "https://10.88.192.1:443"
		}
	}]
	users: [{
		name: "admin@skaia"
		user: {
			"client-certificate-data": string
			"client-key-data":         string
		}
	}]
	contexts: [{
		name: "admin@skaia"
		context: {
			cluster: "skaia"
			user:    "admin@skaia"
		}
	}]
	"current-context": "admin@skaia"
}
