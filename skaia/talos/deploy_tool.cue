package talos

import (
	"cue.skaia/hosts"
	"encoding/yaml"
	"tool/exec"
	"tool/file"
)

hostName: string                                              @tag(host)
address:  string @tag(address)

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
		cmd: ["talosctl", "apply-config", "--talosconfig", writeTalosConfig.filename, "--endpoints", address | *hosts.hosts[hostName].addresses.talosDeploy, "--nodes", address | *hosts.hosts[hostName].addresses.talosDeploy, "--file", writeHostConfig.filename]
	}
}

command: initialDeploy: {
	writeHostConfig: file.Create & {
		filename:    "/tmp/taloshostconfig"
		permissions: 0o600
		contents:    yaml.Marshal(byHost[hostName])
	}
	talosctl: exec.Run & {
		cmd: ["talosctl", "apply-config", "--nodes", address | *hosts.hosts[hostName].addresses.talosInitialDeploy, "--file", writeHostConfig.filename, "--insecure"]
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
