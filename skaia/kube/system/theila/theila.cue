package theila

import (
	"cue.skaia/hosts"
)

resources: talosserviceaccounts: "talos-system": "theila": {
	metadata: labels: "app": "theila"
	spec: roles: ["os:admin"]
}

resources: deployments: "talos-system": "theila": {
	metadata: labels: "app": "theila"
	spec: {
		selector: matchLabels: template.metadata.labels
		template: {
			metadata: labels: "app": "theila"
			spec: {
				containers: [{
					name:  "theila"
					image: "ghcr.io/siderolabs/theila"
					args: ["--address", "0.0.0.0"]
					env: [{
						name:  "TALOSCONFIG"
						value: "/var/run/secrets/talos.dev/config"
					}]
					ports: [{
						name:          "http"
						containerPort: 8080
						protocol:      "TCP"
					}]
					volumeMounts: [{
						name:      "talos-service-account"
						mountPath: "/var/run/secrets/talos.dev"
					}]
					resources: requests: {
						cpu: "1m"
						memory: "22Mi"
					}
				}]
				volumes: [{
					name: "talos-service-account"
					secret: secretName: "theila"
				}]
				hostAliases: [
					for host in hosts.hosts
					if host.isKubeMaster {
						ip: host.addresses.kubeHosts
						hostnames: ["kubeapi.skaia"]
					},
				]
				priorityClassName: "observability"
			}
		}
	}
}

resources: services: "talos-system": "theila": {
	metadata: labels: "app": "theila"
	spec: {
		selector: resources.deployments["talos-system"]["theila"].spec.template.metadata.labels
		ports: [{
			name:       "http"
			port:       80
			protocol:   "TCP"
			targetPort: "http"
		}]
	}
}
