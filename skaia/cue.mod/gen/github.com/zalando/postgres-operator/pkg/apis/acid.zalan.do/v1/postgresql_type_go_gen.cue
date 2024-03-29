// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/zalando/postgres-operator/pkg/apis/acid.zalan.do/v1

package v1

import (
	"k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Postgresql defines PostgreSQL Custom Resource Definition Object.
#Postgresql: _

// PostgresSpec defines the specification for the PostgreSQL TPR.
#PostgresSpec: {
	postgresql:                     #PostgresqlParam         @go(PostgresqlParam)
	volume?:                        #Volume                  @go(Volume)
	patroni?:                       #Patroni                 @go(Patroni)
	resources?:                     null | #Resources        @go(Resources,*Resources)
	enableConnectionPooler?:        null | bool              @go(EnableConnectionPooler,*bool)
	enableReplicaConnectionPooler?: null | bool              @go(EnableReplicaConnectionPooler,*bool)
	connectionPooler?:              null | #ConnectionPooler @go(ConnectionPooler,*ConnectionPooler)
	teamId:                         string                   @go(TeamID)
	dockerImage?:                   string                   @go(DockerImage)
	spiloRunAsUser?:                null | int64             @go(SpiloRunAsUser,*int64)
	spiloRunAsGroup?:               null | int64             @go(SpiloRunAsGroup,*int64)
	spiloFSGroup?:                  null | int64             @go(SpiloFSGroup,*int64)

	// vars that enable load balancers are pointers because it is important to know if any of them is omitted from the Postgres manifest
	// in that case the var evaluates to nil and the value is taken from the operator config
	enableMasterLoadBalancer?:        null | bool @go(EnableMasterLoadBalancer,*bool)
	enableMasterPoolerLoadBalancer?:  null | bool @go(EnableMasterPoolerLoadBalancer,*bool)
	enableReplicaLoadBalancer?:       null | bool @go(EnableReplicaLoadBalancer,*bool)
	enableReplicaPoolerLoadBalancer?: null | bool @go(EnableReplicaPoolerLoadBalancer,*bool)

	// deprecated load balancer settings maintained for backward compatibility
	// see "Load balancers" operator docs
	useLoadBalancer?:     null | bool @go(UseLoadBalancer,*bool)
	replicaLoadBalancer?: null | bool @go(ReplicaLoadBalancer,*bool)

	// load balancers' source ranges are the same for master and replica services
	allowedSourceRanges: [...string] @go(AllowedSourceRanges,[]string)
	users?: {[string]: #UserFlags} @go(Users,map[string]UserFlags)
	usersWithSecretRotation?: [...string] @go(UsersWithSecretRotation,[]string)
	usersWithInPlaceSecretRotation?: [...string] @go(UsersWithInPlaceSecretRotation,[]string)
	numberOfInstances: int32 @go(NumberOfInstances)
	maintenanceWindows?: [...#MaintenanceWindow] @go(MaintenanceWindows,[]MaintenanceWindow)
	clone?: null | #CloneDescription @go(Clone,*CloneDescription)
	databases?: {[string]: string} @go(Databases,map[string]string)
	preparedDatabases?: {[string]: #PreparedDatabase} @go(PreparedDatabases,map[string]PreparedDatabase)
	schedulerName?: null | string           @go(SchedulerName,*string)
	nodeAffinity?:  null | v1.#NodeAffinity @go(NodeAffinity,*v1.NodeAffinity)
	tolerations?: [...v1.#Toleration] @go(Tolerations,[]v1.Toleration)
	sidecars?: [...#Sidecar] @go(Sidecars,[]Sidecar)
	initContainers?: [...v1.#Container] @go(InitContainers,[]v1.Container)
	podPriorityClassName?:  string                     @go(PodPriorityClassName)
	enableShmVolume?:       null | bool                @go(ShmVolume,*bool)
	enableLogicalBackup?:   bool                       @go(EnableLogicalBackup)
	logicalBackupSchedule?: string                     @go(LogicalBackupSchedule)
	standby?:               null | #StandbyDescription @go(StandbyCluster,*StandbyDescription)
	podAnnotations?: {[string]: string} @go(PodAnnotations,map[string]string)
	serviceAnnotations?: {[string]: string} @go(ServiceAnnotations,map[string]string)

	// MasterServiceAnnotations takes precedence over ServiceAnnotations for master role if not empty
	masterServiceAnnotations?: {[string]: string} @go(MasterServiceAnnotations,map[string]string)

	// ReplicaServiceAnnotations takes precedence over ServiceAnnotations for replica role if not empty
	replicaServiceAnnotations?: {[string]: string} @go(ReplicaServiceAnnotations,map[string]string)
	tls?: null | #TLSDescription @go(TLS,*TLSDescription)
	additionalVolumes?: [...#AdditionalVolume] @go(AdditionalVolumes,[]AdditionalVolume)
	streams?: [...#Stream] @go(Streams,[]Stream)
	env?: [...v1.#EnvVar] @go(Env,[]v1.EnvVar)

	// deprecated json tags
	init_containers?: [...v1.#Container] @go(InitContainersOld,[]v1.Container)
	pod_priority_class_name?: string @go(PodPriorityClassNameOld)
}

// PostgresqlList defines a list of PostgreSQL clusters.
#PostgresqlList: {
	metav1.#TypeMeta
	metadata: metav1.#ListMeta @go(ListMeta)
	items: [...#Postgresql] @go(Items,[]Postgresql)
}

// PreparedDatabase describes elements to be bootstrapped
#PreparedDatabase: {
	schemas?: {[string]: #PreparedSchema} @go(PreparedSchemas,map[string]PreparedSchema)
	defaultUsers?: bool @go(DefaultUsers)
	extensions?: {[string]: string} @go(Extensions,map[string]string)
	secretNamespace?: string @go(SecretNamespace)
}

// PreparedSchema describes elements to be bootstrapped per schema
#PreparedSchema: {
	defaultRoles?: null | bool @go(DefaultRoles,*bool)
	defaultUsers?: bool        @go(DefaultUsers)
}

// MaintenanceWindow describes the time window when the operator is allowed to do maintenance on a cluster.
#MaintenanceWindow: _

// Volume describes a single volume in the manifest.
#Volume: {
	selector?:     null | metav1.#LabelSelector @go(Selector,*metav1.LabelSelector)
	size:          string                       @go(Size)
	storageClass?: string                       @go(StorageClass)
	subPath?:      string                       @go(SubPath)
	iops?:         null | int64                 @go(Iops,*int64)
	throughput?:   null | int64                 @go(Throughput,*int64)
	type?:         string                       @go(VolumeType)
}

// AdditionalVolume specs additional optional volumes for statefulset
#AdditionalVolume: {
	name:      string @go(Name)
	mountPath: string @go(MountPath)
	subPath?:  string @go(SubPath)
	targetContainers: [...string] @go(TargetContainers,[]string)
	volumeSource: v1.#VolumeSource @go(VolumeSource)
}

// PostgresqlParam describes PostgreSQL version and pairs of configuration parameter name - values.
#PostgresqlParam: {
	version: string @go(PgVersion)
	parameters?: {[string]: string} @go(Parameters,map[string]string)
}

// ResourceDescription describes CPU and memory resources defined for a cluster.
#ResourceDescription: {
	cpu:    string @go(CPU)
	memory: string @go(Memory)
}

// Resources describes requests and limits for the cluster resouces.
#Resources: {
	requests?: #ResourceDescription @go(ResourceRequests)
	limits?:   #ResourceDescription @go(ResourceLimits)
}

// Patroni contains Patroni-specific configuration
#Patroni: {
	initdb?: {[string]: string} @go(InitDB,map[string]string)
	pg_hba?: [...string] @go(PgHba,[]string)
	ttl?:                     uint32  @go(TTL)
	loop_wait?:               uint32  @go(LoopWait)
	retry_timeout?:           uint32  @go(RetryTimeout)
	maximum_lag_on_failover?: float32 @go(MaximumLagOnFailover)
	slots?: {[string]: [string]: string} @go(Slots,map[string]map[string]string)
	synchronous_mode?:        bool        @go(SynchronousMode)
	synchronous_mode_strict?: bool        @go(SynchronousModeStrict)
	synchronous_node_count?:  uint32      @go(SynchronousNodeCount)
	failsafe_mode?:           null | bool @go(FailsafeMode,*bool)
}

// StandbyDescription contains remote primary config or s3/gs wal path
#StandbyDescription: {
	s3_wal_path?:  string @go(S3WalPath)
	gs_wal_path?:  string @go(GSWalPath)
	standby_host?: string @go(StandbyHost)
	standby_port?: string @go(StandbyPort)
}

// TLSDescription specs TLS properties
#TLSDescription: {
	secretName?:      string @go(SecretName)
	certificateFile?: string @go(CertificateFile)
	privateKeyFile?:  string @go(PrivateKeyFile)
	caFile?:          string @go(CAFile)
	caSecretName?:    string @go(CASecretName)
}

// CloneDescription describes which cluster the new should clone and up to which point in time
#CloneDescription: {
	cluster?:              string      @go(ClusterName)
	uid?:                  string      @go(UID)
	timestamp?:            string      @go(EndTimestamp)
	s3_wal_path?:          string      @go(S3WalPath)
	s3_endpoint?:          string      @go(S3Endpoint)
	s3_access_key_id?:     string      @go(S3AccessKeyId)
	s3_secret_access_key?: string      @go(S3SecretAccessKey)
	s3_force_path_style?:  null | bool @go(S3ForcePathStyle,*bool)
}

// Sidecar defines a container to be run in the same pod as the Postgres container.
#Sidecar: {
	resources?: null | #Resources @go(Resources,*Resources)
	name?:      string            @go(Name)
	image?:     string            @go(DockerImage)
	ports?: [...v1.#ContainerPort] @go(Ports,[]v1.ContainerPort)
	env?: [...v1.#EnvVar] @go(Env,[]v1.EnvVar)
}

// UserFlags defines flags (such as superuser, nologin) that could be assigned to individual users
#UserFlags: [...string]

// PostgresStatus contains status of the PostgreSQL cluster (running, creation failed etc.)
#PostgresStatus: _

// ConnectionPooler Options for connection pooler
//
// TODO: prepared snippets of configuration, one can choose via type, e.g.
// pgbouncer-large (with higher resources) or odyssey-small (with smaller
// resources)
// Type              string `json:"type,omitempty"`
//
// TODO: figure out what other important parameters of the connection pooler it
// makes sense to expose. E.g. pool size (min/max boundaries), max client
// connections etc.
#ConnectionPooler: {
	numberOfInstances?: null | int32      @go(NumberOfInstances,*int32)
	schema?:            string            @go(Schema)
	user?:              string            @go(User)
	mode?:              string            @go(Mode)
	dockerImage?:       string            @go(DockerImage)
	maxDBConnections?:  null | int32      @go(MaxDBConnections,*int32)
	resources?:         null | #Resources @go(Resources,*Resources)
}

// Stream defines properties for creating FabricEventStream resources
#Stream: {
	applicationId: string @go(ApplicationId)
	database:      string @go(Database)
	tables: {[string]: #StreamTable} @go(Tables,map[string]StreamTable)
	filter?: {[string]: null | string} @go(Filter,map[string]*string)
	batchSize?: null | uint32 @go(BatchSize,*uint32)
}

// StreamTable defines properties of outbox tables for FabricEventStreams
#StreamTable: {
	eventType:      string        @go(EventType)
	idColumn?:      null | string @go(IdColumn,*string)
	payloadColumn?: null | string @go(PayloadColumn,*string)
}
