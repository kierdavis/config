package stash

import (
	"secret.cue.skaia:secret"
)

resources: namespaces: "": "stash": {}

resources: secrets: "stash": "stash-license": stringData: "key.txt": secret.stashLicense

resources: secrets: "stash": "b2": {}

resources: deployments: "stash": "stash": spec: template: spec: containers: [{
	name: "operator"
	resources: requests: {
		cpu: "10m"
		memory: "60Mi"
	}
}, {
	name: "pushgateway"
	resources: requests: {
		cpu: "10m"
		memory: "20Mi"
	}
}, ...]

repositoryTemplate: {
	namespace: string
	name: string
	repository: spec: {
		backend: {
			b2: {
				bucket: "KierArchive"
				prefix: "/skaia/stash-0/\(namespace)/\(name)"
			}
			storageSecretName: "b2"
		}
		wipeOut: false
		usagePolicy: allowedNamespaces: {
			from: "Selector"
			selector: matchExpressions: [{
				key: "kubernetes.io/metadata.name"
				operator: "In"
				values: [namespace]
			}]
		}
	}
	resources: backuprepositories: "stash": "\(namespace)-\(name)-b2": repository
}

resources: prometheusrules: stash: "my-rules": spec: groups: [{
	name: "backups",
	rules: [{
		alert: "BackupFailed"
		expr: "stash_backup_session_success == 0"
		labels: severity: "warning"
		annotations: summary: "Backup failed."
		annotations: description: "The last session for {{$labels.invoker_kind}} {{$labels.invoker_name}} in namespace {{$labels.namespace}} was unsuccessful."
	}]
}]
