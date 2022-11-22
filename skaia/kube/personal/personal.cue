package personal

import (
	"cue.skaia/kube/personal/transmission"
)

resources: transmission.resources

resources: namespaces: "": "personal": {}

resources: persistentvolumeclaims: "personal": "torrent-downloads": spec: {
	storageClassName: "ceph-fs-replicated"
	accessModes: ["ReadWriteMany"]
	resources: requests: storage: "300Gi"
}

resources: persistentvolumeclaims: "personal": "coloris-home-20221121": spec: {
	storageClassName: "ceph-blk-replicated"
	accessModes: ["ReadWriteOnce"]
	resources: requests: storage: "51Gi"
}
