package personal

import (
	"cue.skaia/kube/personal/jellyfin"
	"cue.skaia/kube/personal/nameserver"
	"cue.skaia/kube/personal/transmission"
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
	interimVolumeTemplate: spec: {
		storageClassName: "ceph-blk-replicated"
		accessModes: ["ReadWriteOnce"]
		"resources": requests: storage: resources.persistentvolumeclaims.personal.media.spec.resources.requests.storage
	}
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
	schedule: "0 2 * * 2"
	target: ref: {
		apiVersion: "v1"
		kind: "PersistentVolumeClaim"
		name: "media"
	}
	task: name: "pvc-backup"
	timeOut: "6h"
}
resources: backuprepositories: "stash": "personal-media-b2": spec: {
	backend: b2: {
		bucket: "KierArchive"
		prefix: "/skaia/stash-0/personal/media"
	}
	backend: storageSecretName: "b2"
	wipeOut: false
	usagePolicy: allowedNamespaces: {
		from: "Selector"
		selector: matchExpressions: [{
			key: "kubernetes.io/metadata.name"
			operator: "In"
			values: ["personal"]
		}]
	}
}

resources: persistentvolumeclaims: "personal": "coloris-home-20221121": spec: {
	storageClassName: "ceph-blk-replicated"
	accessModes: ["ReadWriteOnce"]
	resources: requests: storage: "51Gi"
}
