package talos

import (
	"cue.skaia/hosts"
	"cue.skaia/networks"
	"secret.cue.skaia:secret"
)

#networkInterfaces: {
	#prospitHost: [
		{
			deviceSelector: driver: "virtio_net"
			dhcp: true
		},
	]
	pyrope: #prospitHost
	serket: #prospitHost
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
			interface: "wg-prospit"
			addresses: ["\(hosts.hosts.megido.addresses.wgMegidoProspit)/\(networks.networks.wgMegidoProspit.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.megido.facing.prospit.private
				listenPort: networks.networks.wgMegidoProspit.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.prospit.facing.megido.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
				}]
			}
			routes: [
				{
					network: networks.networks.prospitHosts.cidr
					gateway: hosts.hosts.prospit.addresses.wgMegidoProspit
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
			interface: "wg-prospit"
			addresses: ["\(hosts.hosts.captor.addresses.wgCaptorProspit)/\(networks.networks.wgCaptorProspit.prefixLength)"]
			wireguard: {
				privateKey: secret.wireguardKeys.captor.facing.prospit.private
				listenPort: networks.networks.wgCaptorProspit.listenPort
				peers: [{
					publicKey: secret.wireguardKeys.prospit.facing.captor.public
					persistentKeepaliveInterval: "59s"
					allowedIPs: ["0.0.0.0/0"]
				}]
			}
			routes: [
				{
					network: networks.networks.prospitHosts.cidr
					gateway: hosts.hosts.prospit.addresses.wgCaptorProspit
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
