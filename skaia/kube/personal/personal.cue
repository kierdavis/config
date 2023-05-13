package personal

import (
	"cue.skaia/kube/personal/git"
	"cue.skaia/kube/personal/jellyfin"
	"cue.skaia/kube/personal/nameserver"
	"cue.skaia/kube/personal/pihole"
	"cue.skaia/kube/personal/transmission"
	"cue.skaia/kube/personal/valheim"
	"cue.skaia/kube/system/stash"
)

resources: git.resources
resources: jellyfin.resources
resources: nameserver.resources
resources: pihole.resources
resources: transmission.resources
resources: valheim.resources

resources: namespaces: "": "personal": {}

resources: persistentvolumeclaims: "personal": "torrent-downloads1": spec: {
	storageClassName: "ceph-fs-media0"
	accessModes: ["ReadWriteMany"]
	resources: requests: storage: "750Gi"
}

resources: persistentvolumeclaims: "personal": "media1": spec: {
	storageClassName: "ceph-fs-media0"
	accessModes: ["ReadWriteMany"]
	resources: requests: storage: "100Gi"
}
resources: backupconfigurations: "personal": "media": spec: {
	driver: "Restic"
	repository: {
		name:      "personal-media-b2"
		namespace: "stash"
	}
	retentionPolicy: {
		name:        "personal-media-b2"
		keepDaily:   7
		keepWeekly:  5
		keepMonthly: 12
		keepYearly:  1000
		prune:       true
	}
	runtimeSettings: pod: priorityClassName: "personal-critical"
	schedule: "0 2 * * 2"
	target: exclude: [".nobackup"]
	target: ref: {
		apiVersion: "v1"
		kind:       "PersistentVolumeClaim"
		name:       "media1"
	}
	task: name: "pvc-backup"
	timeOut: "6h"
}
resources: (stash.repositoryTemplate & {namespace: "personal", name: "media"}).resources

resources: objectbucketclaims: "personal": "archive1": spec: {
	bucketName:       "archive"
	storageClassName: "ceph-obj-gp0"
}
resources: cronjobs: "personal": "archive-backup": spec: {
	concurrencyPolicy:          "Forbid"
	failedJobsHistoryLimit:     1
	schedule:                   "0 2 * * 6"
	successfulJobsHistoryLimit: 3
	jobTemplate: spec: {
		backoffLimit: 0
		template: spec: {
			nodeName:          "maryam"
			restartPolicy:     "Never"
			priorityClassName: "personal-critical"
			volumes: [{name: "config", configMap: name: "archive-backup"}]
			containers: [{
				name:  "main"
				image: "rclone/rclone"
				args: ["copy", "--verbose", "--verbose", "--transfers=1", "--b2-chunk-size=16Mi", "src:archive", "dest:KierArchive"]
				envFrom: [
					{secretRef: name: "archive1"},       // AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY for src
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
	endpoint = http://rook-ceph-rgw-obj-gp0.rook-ceph.svc.kube.skaia
	region =
	location_constraint =
	acl =
	server_side_encryption =
	storage_class =
	[dest]
	type = b2
	"""
resources: secrets: "personal": "archive-backup": {}
