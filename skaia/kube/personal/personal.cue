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
	resources: requests: storage: "150Gi"
}
resources: backupconfigurations: "personal": "media": spec: {
	driver: "Restic"
	repository: {
		name: "personal-media-b2"
		namespace: "stash"
	}
	retentionPolicy: {
		name: "personal-media-b2"
		keepDaily: 7
		keepWeekly: 5
		keepMonthly: 12
		keepYearly: 1000
		prune: true
	}
	runtimeSettings: pod: priorityClassName: "personal-critical"
	schedule: "0 2 * * 2"
	target: exclude: [".nobackup"]
	target: ref: {
		apiVersion: "v1"
		kind: "PersistentVolumeClaim"
		name: "media"
	}
	task: name: "pvc-backup"
	timeOut: "6h"
}
resources: (stash.repositoryTemplate & { namespace: "personal", name: "media" }).resources

resources: objectbucketclaims: "personal": "archive": spec: {
	bucketName: "archive"
	storageClassName: "ceph-obj-archive"
}
resources: cronjobs: "personal": "archive-backup": spec: {
	concurrencyPolicy: "Forbid"
	failedJobsHistoryLimit: 1
	schedule: "0 2 * * 6"
	successfulJobsHistoryLimit: 3
	jobTemplate: spec: {
		backoffLimit: 0
		template: spec: {
			restartPolicy: "Never"
			priorityClassName: "personal-critical"
			volumes: [{name: "config", configMap: name: "archive-backup"}]
			containers: [{
				name: "main"
				image: "rclone/rclone"
				args: ["copy", "--verbose", "src:archive", "dest:KierArchive"]
				envFrom: [
					{secretRef: name: "archive"}, // AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY for src
					{secretRef: name: "archive-backup"}, // RCLONE_B2_ACCOUNT & RCLONE_B2_KEY for dest
				]
				volumeMounts: [{name: "config", mountPath: "/config/rclone", readOnly: true}]
			}]
		}
	}
}
resources: configmaps: "personal": "archive-backup": data: "rclone.conf": """
	[src]
	type = s3
	provider = Ceph
	env_auth = true
	endpoint = http://rook-ceph-rgw-archive.rook-ceph.svc.kube.skaia
	region =
	location_constraint =
	acl =
	server_side_encryption =
	storage_class =
	[dest]
	type = b2
	"""
resources: secrets: "personal": "archive-backup": {}
