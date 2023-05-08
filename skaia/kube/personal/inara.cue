package personal

resources: postgresqls: "personal": "inara-dev-postgres": spec: {
	databases: "dev1": "inara"
	users: "inara": []
	numberOfInstances: 1
	postgresql: version: "15"
	teamId: "inara-dev"
	volume: size: "8Gi"
	volume: storageClass: "ceph-blk-gp0"
}
