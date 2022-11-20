package talos

import (
	"cue.skaia/hosts"
	"encoding/yaml"
	"tool/exec"
	"tool/file"
)

hostName: string                                              @tag(host)
address:  string | *hosts.hosts[hostName].addresses.kubeHosts @tag(address)

command: deploy: {
	writeTalosConfig: file.Create & {
		filename:    "/tmp/talosconfig"
		permissions: 0o600
		contents:    yaml.Marshal(talosconfig)
	}
	writeHostConfig: file.Create & {
		filename:    "/tmp/taloshostconfig"
		permissions: 0o600
		contents:    yaml.Marshal(byHost[hostName])
	}
	talosctl: exec.Run & {
		cmd: ["talosctl", "apply-config", "--talosconfig", writeTalosConfig.filename, "--nodes", address, "--file", writeHostConfig.filename]
	}
}

command: initialDeploy: {
	writeHostConfig: file.Create & {
		filename:    "/tmp/taloshostconfig"
		permissions: 0o600
		contents:    yaml.Marshal(byHost[hostName])
	}
	talosctl: exec.Run & {
		cmd: ["talosctl", "apply-config", "--nodes", address, "--file", writeHostConfig.filename, "--insecure"]
	}
}

command: bootstrapEtcd: {
	writeTalosConfig: file.Create & {
		filename:    "/tmp/talosconfig"
		permissions: 0o600
		contents:    yaml.Marshal(talosconfig)
	}
	talosctl: exec.Run & {
		cmd: ["talosctl", "bootstrap", "--talosconfig", writeTalosConfig.filename, "--nodes", address]
	}
}
