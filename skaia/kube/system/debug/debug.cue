package debug

import (
	"cue.skaia/kube/schema"
)

resources: schema.resources

resources: daemonsets: "talos-system": "host-shell": {
	metadata: labels: app: "host-shell"
	spec: {
		updateStrategy: {
			type: "RollingUpdate"
			rollingUpdate: maxUnavailable: "100%"
		}
		selector: matchLabels: app: "host-shell"
		template: {
			metadata: labels: app: "host-shell"
			spec: {
				hostNetwork: true
				containers: [{
					name:  "shell"
					image: "centos:8"
					command: ["sleep", "infinity"]
					securityContext: privileged: true
					volumeMounts: [{
						name:      "host"
						mountPath: "/host"
						readOnly:  true
					}]
				}]
				volumes: [{
					name: "host"
					hostPath: path: "/"
				}]
				tolerations: [{
					effect:   "NoExecute"
					operator: "Exists"
				}, {
					effect:   "NoSchedule"
					operator: "Exists"
				}]
				priorityClassName: "system-node-critical"
			}
		}
	}
}
