package stash

import (
	"secret.cue.skaia:secret"
)

resources: namespaces: "": "stash": {}

resources: secrets: "stash": "stash-license": stringData: "key.txt": secret.stashLicense
