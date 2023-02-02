package rookceph

defaultScratchMetadataPoolSpec: {
	replicated: size: 1
	failureDomain: "osd"
	parameters: {
		bulk: "0"
		pg_num_min: "1"
	}
}

defaultScratchDataPoolSpec: {
	replicated: size: 1
	failureDomain: "osd"
	parameters: {
		bulk: "1"
		pg_num_min: "1"
	}
}

defaultMetadataPoolSpec: {
	replicated: size: 2
	failureDomain: "osd"
	parameters: {
		bulk: "0"
		pg_num_min: "1"
	}
}

defaultDataPoolSpec: {
	replicated: size: 2
	failureDomain: "osd"
	parameters: {
		bulk: "1"
		pg_num_min: "1"
	}
}

dummyStuffToMakeServerSideApplyHappy: {
	erasureCoded: codingChunks: 0
	erasureCoded: dataChunks: 0
	mirroring: {}
	quotas: {}
	statusCheck: mirror: {}
}

resources: cephblockpools: "rook-ceph": "blk-replicated-metadata": spec: defaultMetadataPoolSpec
resources: cephblockpools: "rook-ceph": "blk-replicated-data": spec: defaultDataPoolSpec
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
	metadataPool: defaultMetadataPoolSpec
	dataPools: [
		// https://tracker.ceph.com/issues/42450
		// The first (default) pool contains gluey inode backtrace stuff and must be replicated.
		// All the file contents will actually be stored in the second pool.
		{ name: "inode-backtraces" } & defaultMetadataPoolSpec & dummyStuffToMakeServerSideApplyHappy,
		{ name: "data" } & defaultDataPoolSpec & dummyStuffToMakeServerSideApplyHappy,
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
