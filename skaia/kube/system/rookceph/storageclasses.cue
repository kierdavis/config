package rookceph

poolTemplates: {
	base: {
		failureDomain: "osd"
		replicated: size: 2
		parameters: pg_num_min: "1"
	}
	nonBulk: base & {
		parameters: bulk: "0"
	}
	bulk: base & {
		parameters: bulk: "1"
	}
	listElement: base & {
		// When pool specs are put in a list (e.g. in CephFilesystem's dataPools),
		// server-side apply gets a bit confused, and we need to manage a bunch of
		// fields to stop it going weird. I forgot the details.
		erasureCoded: codingChunks: 0
		erasureCoded: dataChunks: 0
		mirroring: {}
		quotas: {}
		statusCheck: mirror: {}
	}
}

resources: cephblockpools: "rook-ceph": "blk-replicated-metadata": spec: poolTemplates.nonBulk
resources: cephblockpools: "rook-ceph": "blk-replicated-data": spec: poolTemplates.bulk
resources: storageclasses: "": "ceph-blk-replicated": {
	provisioner: "rook-ceph.rbd.csi.ceph.com"
	reclaimPolicy: "Delete"
	allowVolumeExpansion: true
	parameters: {
		clusterID: "rook-ceph"
		pool: "blk-replicated-metadata"
		dataPool: "blk-replicated-data"
		"csi.storage.k8s.io/fstype": "ext4"
		"csi.storage.k8s.io/provisioner-secret-name": "rook-csi-rbd-provisioner"
		"csi.storage.k8s.io/provisioner-secret-namespace": "rook-ceph"
		"csi.storage.k8s.io/controller-expand-secret-name": "rook-csi-rbd-provisioner"
		"csi.storage.k8s.io/controller-expand-secret-namespace": "rook-ceph"
		"csi.storage.k8s.io/node-stage-secret-name": "rook-csi-rbd-node"
		"csi.storage.k8s.io/node-stage-secret-namespace": "rook-ceph"
	}
}

resources: cephfilesystems: "rook-ceph": "fs-replicated": spec: {
	metadataPool: poolTemplates.nonBulk
	dataPools: [
		// https://tracker.ceph.com/issues/42450
		// The first (default) pool contains gluey inode backtrace stuff and must be replicated.
		// All the file contents will actually be stored in the second pool.
		{ name: "inode-backtraces" } & poolTemplates.nonBulk & poolTemplates.listElement,
		{ name: "data" } & poolTemplates.bulk & poolTemplates.listElement,
	]
	metadataServer: {
		activeCount: 1  // Controls sharding, not redundancy.
		priorityClassName: "system-cluster-critical"
		resources: {
			requests: cpu: "80m"
			requests: memory: "80Mi"
		}
	}
}
resources: storageclasses: "": "ceph-fs-replicated": {
	provisioner: "rook-ceph.cephfs.csi.ceph.com"
	reclaimPolicy: "Delete"
	allowVolumeExpansion: true
	parameters: {
		clusterID: "rook-ceph"
		fsName: "fs-replicated"
		pool: "fs-replicated-data"
		"csi.storage.k8s.io/provisioner-secret-name": "rook-csi-cephfs-provisioner"
		"csi.storage.k8s.io/provisioner-secret-namespace": "rook-ceph"
		"csi.storage.k8s.io/controller-expand-secret-name": "rook-csi-cephfs-provisioner"
		"csi.storage.k8s.io/controller-expand-secret-namespace": "rook-ceph"
		"csi.storage.k8s.io/node-stage-secret-name": "rook-csi-cephfs-node"
		"csi.storage.k8s.io/node-stage-secret-namespace": "rook-ceph"
	}
}

resources: cephobjectstores: "rook-ceph": "archive": spec: {
	metadataPool: poolTemplates.nonBulk
	dataPool: poolTemplates.bulk
	preservePoolsOnDelete: true
	gateway: {
		port: 80
		instances: 1
	}
}
resources: storageclasses: "": "ceph-obj-archive": {
	provisioner: "rook-ceph.ceph.rook.io/bucket"
	reclaimPolicy: "Delete"
	parameters: {
		objectStoreName: "archive"
		objectStoreNamespace: "rook-ceph"
	}
}
