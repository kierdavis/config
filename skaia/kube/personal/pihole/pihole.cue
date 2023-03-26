package pihole

serverLabels: {
	app:       "pihole"
	component: "dns"
}

resources: deployments: personal: pihole: {
	metadata: "labels": serverLabels
	spec: {
		selector: matchLabels: serverLabels
		replicas: 1
		template: {
			metadata: "labels": serverLabels
			spec: {
				priorityClassName: "personal-critical"
				dnsConfig: nameservers: ["127.0.0.1", "1.1.1.1", "1.0.0.1"]
				containers: [{
					name:  "main"
					image: "pihole/pihole"
					env: [
						{name: "DNSMASQ_LISTENING", value: "all"},
						{name: "PIHOLE_DNS_", value:       "1.1.1.1;1.0.0.1"},
						{name: "TZ", value:                "Europe/London"},
						{name: "VIRTUAL_HOST", value:      "pihole.personal.svc.kube.skaia"},
						{name: "WEBLOGS_STDOUT", value:    "1"},
						{name: "WEBPASSWORD", value:       "admin"},
					]
					ports: [
						{name: "dns-tcp", containerPort: 53, protocol: "TCP"},
						{name: "dns-udp", containerPort: 53, protocol: "UDP"},
						{name: "ui", containerPort:      80, protocol: "TCP"},
					]
				}]
			}
		}
	}
}

resources: services: personal: pihole: {
	metadata: "labels": serverLabels
	spec: {
		selector: serverLabels
		ports: [
			{name: "dns-tcp", port: 53, protocol: "TCP", targetPort: "dns-tcp"},
			{name: "dns-udp", port: 53, protocol: "UDP", targetPort: "dns-udp"},
			{name: "ui", port:      80, protocol: "TCP", targetPort: "ui"},
		]
	}
}

exporterLabels: {
	app:       "pihole"
	component: "exporter"
}

resources: deployments: personal: "pihole-exporter": {
	metadata: "labels": exporterLabels
	spec: {
		selector: matchLabels: exporterLabels
		replicas: 1
		template: {
			metadata: "labels": exporterLabels
			spec: {
				priorityClassName: "observability"
				containers: [{
					name:  "main"
					image: "ekofr/pihole-exporter"
					env: [
						{name: "PIHOLE_HOSTNAME", value: "pihole.personal.svc.kube.skaia"},
						{name: "PIHOLE_PORT", value:     "80"},
						{name: "PIHOLE_PASSWORD", value: "admin"},
						{name: "PORT", value:            "80"},
					]
					ports: [
						{name: "metrics", containerPort: 80, protocol: "TCP"},
					]
				}]
			}
		}
	}
}

resources: services: personal: "pihole-exporter": {
	metadata: "labels": exporterLabels
	spec: {
		selector: exporterLabels
		ports: [
			{name: "metrics", port: 80, protocol: "TCP", targetPort: "metrics"},
		]
	}
}

resources: servicemonitors: personal: pihole: {
	metadata: "labels": exporterLabels
	spec: {
		selector: matchLabels: exporterLabels
		endpoints: [{port: "metrics"}]
	}
}
