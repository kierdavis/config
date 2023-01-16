package stash

import (
	"secret.cue.skaia:secret"
)

resources: namespaces: "": "stash": {}

resources: secrets: "stash": "stash-license": stringData: "key.txt": secret.stashLicense

resources: secrets: "stash": "b2": {}

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
