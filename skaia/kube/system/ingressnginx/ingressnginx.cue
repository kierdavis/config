package ingressnginx

#socketService: {
	frontendPort:     >20000 & <21000
	backendNamespace: string
	backendName:      string
	backendPort:      uint16
}

tcpServices: [string]: #socketService
udpServices: [string]: #socketService

tcpServices: "git-ssh": {
	frontendPort:     20001
	backendNamespace: "personal"
	backendName:      "git"
	backendPort:      22
}

resources: configmaps: "ingress-nginx": "tcp-services": data: {
	for _, service in tcpServices {
		"\(service.frontendPort)": "\(service.backendNamespace)/\(service.backendName):\(service.backendPort)"
	}
}

resources: configmaps: "ingress-nginx": "udp-services": data: {
	for _, service in udpServices {
		"\(service.frontendPort)": "\(service.backendNamespace)/\(service.backendName):\(service.backendPort)"
	}
}

resources: daemonsets: "ingress-nginx": "ingress-nginx-controller": spec: template: spec: containers: [{
	ports: [
		{
			containerPort: 80
			name:          "http"
			protocol:      "TCP"
		},
		{
			containerPort: 443
			name:          "https"
			protocol:      "TCP"
		},
		{
			containerPort: 8443
			name:          "webhook"
			protocol:      "TCP"
		},
		for serviceName, service in tcpServices {
			containerPort: service.frontendPort
			name:          serviceName
			protocol:      "TCP"
		},
		for serviceName, service in udpServices {
			containerPort: service.frontendPort
			name:          serviceName
			protocol:      "UDP"
		},
	]
}]
