package hist5

hobgoblin: runtime: failure_reminder_interval: 120

hobgoblin: constraints: {
	for machineName, machine in machines
	if machine.addresses.internet != null
	{ "\(machineName) internet address does not respond to ping": {
		"type": "ping"
		"address": machine.addresses.internet
		"expected_state": "unresponsive"
	}}
}

hobgoblin: constraints: {
	for machineName, machine in machines
	{ "\(machineName) wireguard address responds to ping": {
		"type": "ping"
		"address": machine.addresses.wireguard
		"expected_state": "responsive"
	}}
}

hobgoblin: constraints: {
	for machineName, machine in machines
	if machine.isKubeNode
	{ "all talos services on \(machineName) are running": {
		"type": "talos_services"
		"node_address": machine.addresses.wireguard
		"talosconfig": talosconfig
	}}
}

hobgoblin: constraints: {
	for machineName, machine in machines
	if machine.isKubeNode
	{ "kubernetes node \(machineName) is ready": {
		"type": "kubernetes_node_ready"
		"name": machineName
		"kubeconfig": kubeconfig
	}}
}

//hobgoblin: constraints: "inter-pod networking works": {
//	"type": "kubernetes_pod_networking"
//	"namespace": "monitoring"
//	"kubeconfig": kubeconfig
//}
