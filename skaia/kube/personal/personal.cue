package personal

import (
	"cue.skaia/kube/personal/jellyfin"
	"cue.skaia/kube/personal/nameserver"
	"cue.skaia/kube/personal/transmission"
	"cue.skaia/kube/system/stash"
)

resources: jellyfin.resources
resources: nameserver.resources
resources: transmission.resources

resources: namespaces: "": "personal": {}

resources: persistentvolumeclaims: "personal": "torrent-downloads": spec: {
	storageClassName: "ceph-fs-replicated"
	accessModes: ["ReadWriteMany"]
	resources: requests: storage: "500Gi"
}

resources: persistentvolumeclaims: "personal": "media": spec: {
	storageClassName: "ceph-fs-replicated"
	accessModes: ["ReadWriteMany"]
	resources: requests: storage: "10Gi"
}
resources: backupconfigurations: "personal": "media": spec: {
	driver: "Restic"
	repository: {
		name: "personal-media-b2"
		namespace: "stash"
	}
	retentionPolicy: {
		name: "personal-media-b2"
		keepWeekly: 1
		keepMonthly: 1
		keepYearly: 1
		prune: true
	}
	runtimeSettings: pod: priorityClassName: "personal-critical"
	schedule: "0 2 * * 2"
	target: ref: {
		apiVersion: "v1"
		kind: "PersistentVolumeClaim"
		name: "media"
	}
	task: name: "pvc-backup"
	timeOut: "6h"
}
resources: (stash.repositoryTemplate & { namespace: "personal", name: "media" }).resources
