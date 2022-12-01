package nameserver

import (
	"cue.skaia/kube/util"
)

labels: app: "nameserver"

config: util.HashedConfigMap & {
	namespace: "personal"
	namePrefix: "nameserver"
	metadata: "labels": labels
	data: "Corefile": """
		(common) {
			errors
			log . {
				class error
			}
			health {
				lameduck 5s
			}
			ready
			prometheus :9153

			cancel
			cache 30
			loop
		}

		. {
			import common
			forward . 1.1.1.1 1.0.0.1
		}

		skaia {
			import common
			header {
				# Screw you - I'm authoratitive for skaia.
				set aa ra
			}
			file /etc/coredns/skaia {
				reload 0s
			}
		}

		kube.skaia {
			import common
			header {
				# Screw you - I'm authoratitive for kube.skaia.
				set aa ra
			}
			forward . 10.88.192.10
		}
		"""
	data: "skaia": """
		$ORIGIN skaia.
		@ 3600 IN SOA nameserver.personal.svc.kube.skaia. me.kierdavis.com. 2022112300 7200 3600 1209600 3600
		@ 3600 IN NS nameserver.personal.svc.kube.skaia.
		ceph IN CNAME rook-ceph-mgr-dashboard.rook-ceph.svc.kube.skaia.
		dns IN CNAME nameserver.personal.svc.kube.skaia.
		metrics IN CNAME grafana.monitoring.svc.kube.skaia.
		talos IN CNAME theila.talos-system.svc.kube.skaia.
		torrents IN CNAME transmission.personal.svc.kube.skaia.
		"""
}
resources: config.resources

resources: deployments: personal: nameserver: metadata: "labels": labels
resources: deployments: personal: nameserver: spec: {
	selector: matchLabels: labels
	replicas: 2
	template: {
		metadata: "labels": labels
		spec: {
			priorityClassName: "personal-critical"
			containers: [{
				name: "coredns"
				image: "docker.io/coredns/coredns:1.9.3"
				args: ["-conf", "/etc/coredns/Corefile"]
				ports: [
					{ name: "dns-tcp", containerPort: 53, protocol: "TCP" },
					{ name: "dns-udp", containerPort: 53, protocol: "UDP" },
					{ name: "metrics", containerPort: 9153, protocol: "TCP" },
				]
				volumeMounts: [
					{ name: "config", mountPath: "/etc/coredns", readOnly: true },
				]
				resources: {
					requests: cpu: "100m"
					requests: memory: "70Mi"
					limits: memory: "170Mi"
				}
				securityContext: {
					allowPrivilegeEscalation: false
					readOnlyRootFilesystem: true
					capabilities: add: ["NET_BIND_SERVICE"]
					capabilities: drop: ["all"]
				}
				livenessProbe: {
					httpGet: {
						path: "/health"
						port: 8080
						scheme: "HTTP"
					}
					initialDelaySeconds: 60
					periodSeconds: 10
					timeoutSeconds: 5
					successThreshold: 1
					failureThreshold: 5
				}
				readinessProbe: {
					httpGet: {
						path: "/ready",
						port: 8181
						scheme: "HTTP"
					}
					periodSeconds: 10
					failureThreshold: 3
					successThreshold: 1
					timeoutSeconds: 1
				}
			}]
			volumes: [
				{ name: "config", configMap: name: config.computedName },
			]
		}
	}
}

resources: services: personal: nameserver: metadata: "labels": labels
resources: services: personal: nameserver: spec: {
	selector: labels
	ports: [
		{ name: "dns-tcp", port: 53, protocol: "TCP", targetPort: "dns-tcp" },
		{ name: "dns-udp", port: 53, protocol: "UDP", targetPort: "dns-udp" },
	]
}

resources: servicemonitors: personal: nameserver: metadata: "labels": labels
resources: servicemonitors: personal: nameserver: spec: {
	selector: matchLabels: labels
	endpoints: [{ port: "metrics" }]
}
