package kube

import (
	"cue.skaia/talos"
	"encoding/yaml"
	"tool/exec"
	"list"
	"tool/file"
)

earlyKinds: ["customresourcedefinitions", "namespaces"]

resourceList: [
	for kind, resourcesOfKind in resources
	if list.Contains(earlyKinds, kind)
	for _, resourcesInNs in resourcesOfKind
	for _, resource in resourcesInNs {resource},
	for kind, resourcesOfKind in resources
	if !list.Contains(earlyKinds, kind)
	for _, resourcesInNs in resourcesOfKind
	for _, resource in resourcesInNs {resource},
]

command: deploy: {
	writeKubeConfig: file.Create & {
		filename:    "/tmp/kubeconfig"
		permissions: 0o600
		contents:    yaml.Marshal(talos.kubeconfig)
	}
	writeResources: file.Create & {
		filename:    "/tmp/kube-resources.yaml"
		permissions: 0o600
		contents:    yaml.MarshalStream(resourceList)
	}
	applyResources: exec.Run & {
		cmd: [
			"kubectl",
			"--kubeconfig", writeKubeConfig.filename,
			"apply",
			"--server-side",
			// Pending resolution of https://github.com/kubernetes/kubernetes/issues/110893
			//"--prune",
			//"--all",
			"--filename", writeResources.filename,
		]
	}
}

command: export: {
	writeResources: file.Create & {
		filename:    "/tmp/kube-resources.yaml"
		permissions: 0o600
		contents:    yaml.MarshalStream(resourceList)
	}
}
