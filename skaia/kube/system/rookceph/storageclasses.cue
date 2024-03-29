package rookceph

poolTemplates: {
	base: {
		failureDomain: "osd"
		replicated: size:       2
		parameters: pg_num_min: "1"
	}
	nonBulk: base & {
		parameters: bulk: "0"
	}
	bulk: base & {
		parameters: bulk: "1"
	}
	onlySSD: base & {
		deviceClass: "ssd"
	}
	listElement: base & {
		// When pool specs are put in a list (e.g. in CephFilesystem's dataPools),
		// server-side apply gets a bit confused, and we need to manage a bunch of
		// fields to stop it going weird. I forgot the details.
		erasureCoded: codingChunks: 0
		erasureCoded: dataChunks:   0
		mirroring: {}
		quotas: {}
		statusCheck: mirror: {}
	}
}

filesystemTemplate: spec: {
	metadataPool: poolTemplates.nonBulk
	dataPools: [{name: "data"} & poolTemplates.bulk & poolTemplates.listElement]
	metadataServer: {
		activeCount:       1 // Controls sharding, not redundancy.
		priorityClassName: "system-cluster-critical"
		resources: {
			requests: cpu:    "80m"
			requests: memory: "80Mi"
		}
	}
}

objectStoreTemplate: spec: {
	metadataPool:          poolTemplates.nonBulk
	dataPool:              poolTemplates.bulk
	gateway: {
		port:      80
		instances: 1
		placement: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
			matchExpressions: [{key: "topology.kubernetes.io/zone", operator: "In", values: ["zone-advent-way"]}]
		}]
	}
}

storageClassTemplates: {
	blk: {
		provisioner:          "rook-ceph.rbd.csi.ceph.com"
		reclaimPolicy:        "Delete"
		allowVolumeExpansion: true
		parameters: {
			clusterID:                                               "rook-ceph"
			pool:                                                    string // metadata pool
			dataPool:                                                string
			"csi.storage.k8s.io/fstype":                             "ext4"
			"csi.storage.k8s.io/provisioner-secret-name":            "rook-csi-rbd-provisioner"
			"csi.storage.k8s.io/provisioner-secret-namespace":       "rook-ceph"
			"csi.storage.k8s.io/controller-expand-secret-name":      "rook-csi-rbd-provisioner"
			"csi.storage.k8s.io/controller-expand-secret-namespace": "rook-ceph"
			"csi.storage.k8s.io/node-stage-secret-name":             "rook-csi-rbd-node"
			"csi.storage.k8s.io/node-stage-secret-namespace":        "rook-ceph"
		}
	}
	fs: {
		provisioner:          "rook-ceph.cephfs.csi.ceph.com"
		reclaimPolicy:        "Delete"
		allowVolumeExpansion: true
		parameters: {
			clusterID:                                               "rook-ceph"
			fsName:                                                  string
			pool:                                                    "\(fsName)-data"
			"csi.storage.k8s.io/provisioner-secret-name":            "rook-csi-cephfs-provisioner"
			"csi.storage.k8s.io/provisioner-secret-namespace":       "rook-ceph"
			"csi.storage.k8s.io/controller-expand-secret-name":      "rook-csi-cephfs-provisioner"
			"csi.storage.k8s.io/controller-expand-secret-namespace": "rook-ceph"
			"csi.storage.k8s.io/node-stage-secret-name":             "rook-csi-cephfs-node"
			"csi.storage.k8s.io/node-stage-secret-namespace":        "rook-ceph"
		}
	}
	obj: {
		provisioner:   "rook-ceph.ceph.rook.io/bucket"
		reclaimPolicy: "Delete"
		parameters: {
			objectStoreName:      string
			objectStoreNamespace: "rook-ceph"
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////// ceph-blk-gp0: general-purpose block storage /////////////////
///////////////////////////////////////////////////////////////////////////////

resources: cephblockpools: "rook-ceph": "blk-gp0-metadata": spec: poolTemplates.nonBulk
resources: cephblockpools: "rook-ceph": "blk-gp0-data": spec:     poolTemplates.bulk
resources: storageclasses: "": "ceph-blk-gp0": storageClassTemplates.blk & {
	parameters: pool:     "blk-gp0-metadata"
	parameters: dataPool: "blk-gp0-data"
}

///////////////////////////////////////////////////////////////////////////////
////////////////// ceph-blk-hot0: low-latency block storage ///////////////////
///////////////////////////////////////////////////////////////////////////////

resources: cephblockpools: "rook-ceph": "blk-hot0-metadata": spec: poolTemplates.nonBulk & poolTemplates.onlySSD
resources: cephblockpools: "rook-ceph": "blk-hot0-data": spec:     poolTemplates.bulk & poolTemplates.onlySSD
resources: storageclasses: "": "ceph-blk-hot0": storageClassTemplates.blk & {
	parameters: pool:     "blk-hot0-metadata"
	parameters: dataPool: "blk-hot0-data"
}

///////////////////////////////////////////////////////////////////////////////
////////// ceph-blk-media0: block storage for entertainment & media ///////////
///////////////////////////////////////////////////////////////////////////////

// Identical to ceph-blk-gp0 for now, but it's a candidate for pinning to
// storage that's physically located at home for better playback latency.

resources: cephblockpools: "rook-ceph": "blk-media0-metadata": spec: poolTemplates.nonBulk
resources: cephblockpools: "rook-ceph": "blk-media0-data": spec:     poolTemplates.bulk
resources: storageclasses: "": "ceph-blk-media0": storageClassTemplates.blk & {
	parameters: pool:     "blk-media0-metadata"
	parameters: dataPool: "blk-media0-data"
}

///////////////////////////////////////////////////////////////////////////////
/////////////// ceph-fs-gp0: general-purpose shared filesystem ////////////////
///////////////////////////////////////////////////////////////////////////////

resources: cephfilesystems: "rook-ceph": "fs-gp0": filesystemTemplate
resources: storageclasses: "": "ceph-fs-gp0":      storageClassTemplates.fs & {
	parameters: fsName: "fs-gp0"
}

///////////////////////////////////////////////////////////////////////////////
///////// ceph-fs-media0: shared filesystem for entertainment & media /////////
///////////////////////////////////////////////////////////////////////////////

// Identical to ceph-fs-gp0 for now, but it's a candidate for pinning to
// storage that's physically located at home for better playback latency.

resources: cephfilesystems: "rook-ceph": "fs-media0": filesystemTemplate
resources: storageclasses: "": "ceph-fs-media0":      storageClassTemplates.fs & {
	parameters: fsName: "fs-media0"
}

///////////////////////////////////////////////////////////////////////////////
//////////////// ceph-obj-gp0: general-purpose object storage /////////////////
///////////////////////////////////////////////////////////////////////////////

resources: cephobjectstores: "rook-ceph": "obj-gp0": objectStoreTemplate
resources: storageclasses: "": "ceph-obj-gp0": storageClassTemplates.obj & {
	parameters: objectStoreName: "obj-gp0"
}
