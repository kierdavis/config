package jellyfin

labels: app: "jellyfin"

resources: statefulsets: personal: jellyfin: {
	metadata: "labels": labels
	spec: {
		selector: matchLabels: labels
		serviceName: "jellyfin"
		replicas: 1
		template: {
			metadata: "labels": labels
			spec: {
				containers: [{
					name: "jellyfin"
					image: "linuxserver/jellyfin"
					env: [
						{ name: "TZ", value: "Europe/London" },
					]
					ports: [
						{ name: "ui", containerPort: 8096 },
					]
					volumeMounts: [
						{ name: "database", mountPath: "/config", readOnly: false },
						{ name: "transcodes", mountPath: "/config/data/transcodes", readOnly: false },
						{ name: "media", mountPath: "/net/skaia/media", readOnly: true },
						{ name: "torrent-downloads", mountPath: "/net/skaia/torrent-downloads", readOnly: true },
					]
					resources: {
						requests: cpu: "1"
						requests: memory: "2Gi"
						limits: requests
					}
				}]
				volumes: [
					{ name: "media", persistentVolumeClaim: { claimName: "media", readOnly: true } },
					{ name: "torrent-downloads", persistentVolumeClaim: { claimName: "torrent-downloads", readOnly: true } },
				]
			}
		}
		volumeClaimTemplates: [
			{
				metadata: name: "database"
				spec: {
					accessModes: ["ReadWriteOnce"]
					storageClassName: "ceph-blk-replicated"
					resources: requests: storage: "2Gi"
				}
			},
			{
				metadata: name: "transcodes"
				spec: {
					accessModes: ["ReadWriteOnce"]
					storageClassName: "ceph-blk-scratch"
					resources: requests: storage: "20Gi"
				}
			},
		]
	}
}

resources: services: personal: jellyfin: {
	metadata: "labels": labels
	spec: {
		selector: labels
		ports: [
			{
				name: "ui"
				port: 80
				targetPort: "ui"
				appProtocol: "http"
			},
		]
	}
}
