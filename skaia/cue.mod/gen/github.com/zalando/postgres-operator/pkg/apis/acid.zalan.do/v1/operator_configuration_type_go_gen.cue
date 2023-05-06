// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/zalando/postgres-operator/pkg/apis/acid.zalan.do/v1

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"github.com/zalando/postgres-operator/pkg/util/config"
	"k8s.io/api/core/v1"
)

// OperatorConfiguration defines the specification for the OperatorConfiguration.
#OperatorConfiguration: {
	metav1.#TypeMeta
	metadata:      metav1.#ObjectMeta         @go(ObjectMeta)
	configuration: #OperatorConfigurationData @go(Configuration)
}

// OperatorConfigurationList is used in the k8s API calls
#OperatorConfigurationList: {
	metav1.#TypeMeta
	metadata: metav1.#ListMeta @go(ListMeta)
	items: [...#OperatorConfiguration] @go(Items,[]OperatorConfiguration)
}

// PostgresUsersConfiguration defines the system users of Postgres.
#PostgresUsersConfiguration: {
	super_username?:       string @go(SuperUsername)
	replication_username?: string @go(ReplicationUsername)
	additional_owner_roles?: [...string] @go(AdditionalOwnerRoles,[]string)
	enable_password_rotation?:         bool   @go(EnablePasswordRotation)
	password_rotation_interval?:       uint32 @go(PasswordRotationInterval)
	password_rotation_user_retention?: uint32 @go(PasswordRotationUserRetention)
}

// MajorVersionUpgradeConfiguration defines how to execute major version upgrades of Postgres.
#MajorVersionUpgradeConfiguration: {
	major_version_upgrade_mode: string @go(MajorVersionUpgradeMode)
	major_version_upgrade_team_allow_list?: [...string] @go(MajorVersionUpgradeTeamAllowList,[]string)
	minimal_major_version: string @go(MinimalMajorVersion)
	target_major_version:  string @go(TargetMajorVersion)
}

// KubernetesMetaConfiguration defines k8s conf required for all Postgres clusters and the operator itself
#KubernetesMetaConfiguration: {
	pod_service_account_name?: string @go(PodServiceAccountName)

	// TODO: change it to the proper json
	pod_service_account_definition?:              string       @go(PodServiceAccountDefinition)
	pod_service_account_role_binding_definition?: string       @go(PodServiceAccountRoleBindingDefinition)
	pod_terminate_grace_period?:                  #Duration    @go(PodTerminateGracePeriod)
	spilo_privileged?:                            bool         @go(SpiloPrivileged)
	spilo_allow_privilege_escalation?:            null | bool  @go(SpiloAllowPrivilegeEscalation,*bool)
	spilo_runasuser?:                             null | int64 @go(SpiloRunAsUser,*int64)
	spilo_runasgroup?:                            null | int64 @go(SpiloRunAsGroup,*int64)
	spilo_fsgroup?:                               null | int64 @go(SpiloFSGroup,*int64)
	additional_pod_capabilities?: [...string] @go(AdditionalPodCapabilities,[]string)
	watched_namespace?:                string                 @go(WatchedNamespace)
	pdb_name_format?:                  config.#StringTemplate @go(PDBNameFormat)
	enable_pod_disruption_budget?:     null | bool            @go(EnablePodDisruptionBudget,*bool)
	storage_resize_mode?:              string                 @go(StorageResizeMode)
	enable_init_containers?:           null | bool            @go(EnableInitContainers,*bool)
	enable_sidecars?:                  null | bool            @go(EnableSidecars,*bool)
	share_pgsocket_with_sidecars?:     null | bool            @go(SharePgSocketWithSidecars,*bool)
	secret_name_template?:             config.#StringTemplate @go(SecretNameTemplate)
	cluster_domain?:                   string                 @go(ClusterDomain)
	oauth_token_secret_name?:          string   @go(OAuthTokenSecretName)
	infrastructure_roles_secret_name?: string   @go(InfrastructureRolesSecretName)
	infrastructure_roles_secrets?: [...null | config.#InfrastructureRole] @go(InfrastructureRolesDefs,[]*config.InfrastructureRole)
	pod_role_label?: string @go(PodRoleLabel)
	cluster_labels?: {[string]: string} @go(ClusterLabels,map[string]string)
	inherited_labels?: [...string] @go(InheritedLabels,[]string)
	inherited_annotations?: [...string] @go(InheritedAnnotations,[]string)
	downscaler_annotations?: [...string] @go(DownscalerAnnotations,[]string)
	ignored_annotations?: [...string] @go(IgnoredAnnotations,[]string)
	cluster_name_label?:         string @go(ClusterNameLabel)
	delete_annotation_date_key?: string @go(DeleteAnnotationDateKey)
	delete_annotation_name_key?: string @go(DeleteAnnotationNameKey)
	node_readiness_label?: {[string]: string} @go(NodeReadinessLabel,map[string]string)
	node_readiness_label_merge?: string @go(NodeReadinessLabelMerge)
	custom_pod_annotations?: {[string]: string} @go(CustomPodAnnotations,map[string]string)

	// TODO: use a proper toleration structure?
	toleration?: {[string]: string} @go(PodToleration,map[string]string)
	pod_environment_configmap?:                    string @go(PodEnvironmentConfigMap)
	pod_environment_secret?:                       string               @go(PodEnvironmentSecret)
	pod_priority_class_name?:                      string               @go(PodPriorityClassName)
	master_pod_move_timeout?:                      #Duration            @go(MasterPodMoveTimeout)
	enable_pod_antiaffinity?:                      bool                 @go(EnablePodAntiAffinity)
	pod_antiaffinity_preferred_during_scheduling?: bool                 @go(PodAntiAffinityPreferredDuringScheduling)
	pod_antiaffinity_topology_key?:                string               @go(PodAntiAffinityTopologyKey)
	pod_management_policy?:                        string               @go(PodManagementPolicy)
	enable_readiness_probe?:                       bool                 @go(EnableReadinessProbe)
	enable_cross_namespace_secret?:                bool                 @go(EnableCrossNamespaceSecret)
}

// PostgresPodResourcesDefaults defines the spec of default resources
#PostgresPodResourcesDefaults: {
	default_cpu_request?:    string @go(DefaultCPURequest)
	default_memory_request?: string @go(DefaultMemoryRequest)
	default_cpu_limit?:      string @go(DefaultCPULimit)
	default_memory_limit?:   string @go(DefaultMemoryLimit)
	min_cpu_limit?:          string @go(MinCPULimit)
	min_memory_limit?:       string @go(MinMemoryLimit)
	max_cpu_request?:        string @go(MaxCPURequest)
	max_memory_request?:     string @go(MaxMemoryRequest)
}

// OperatorTimeouts defines the timeout of ResourceCheck, PodWait, ReadyWait
#OperatorTimeouts: {
	resource_check_interval?:    #Duration @go(ResourceCheckInterval)
	resource_check_timeout?:     #Duration @go(ResourceCheckTimeout)
	pod_label_wait_timeout?:     #Duration @go(PodLabelWaitTimeout)
	pod_deletion_wait_timeout?:  #Duration @go(PodDeletionWaitTimeout)
	ready_wait_interval?:        #Duration @go(ReadyWaitInterval)
	ready_wait_timeout?:         #Duration @go(ReadyWaitTimeout)
	patroni_api_check_interval?: #Duration @go(PatroniAPICheckInterval)
	patroni_api_check_timeout?:  #Duration @go(PatroniAPICheckTimeout)
}

// LoadBalancerConfiguration defines the LB configuration
#LoadBalancerConfiguration: {
	db_hosted_zone?:                      string @go(DbHostedZone)
	enable_master_load_balancer?:         bool   @go(EnableMasterLoadBalancer)
	enable_master_pooler_load_balancer?:  bool   @go(EnableMasterPoolerLoadBalancer)
	enable_replica_load_balancer?:        bool   @go(EnableReplicaLoadBalancer)
	enable_replica_pooler_load_balancer?: bool   @go(EnableReplicaPoolerLoadBalancer)
	custom_service_annotations?: {[string]: string} @go(CustomServiceAnnotations,map[string]string)
	master_dns_name_format?:         config.#StringTemplate @go(MasterDNSNameFormat)
	master_legacy_dns_name_format?:  config.#StringTemplate @go(MasterLegacyDNSNameFormat)
	replica_dns_name_format?:        config.#StringTemplate @go(ReplicaDNSNameFormat)
	replica_legacy_dns_name_format?: config.#StringTemplate @go(ReplicaLegacyDNSNameFormat)
	external_traffic_policy:         string                 @go(ExternalTrafficPolicy)
}

// AWSGCPConfiguration defines the configuration for AWS
// TODO complete Google Cloud Platform (GCP) configuration
#AWSGCPConfiguration: {
	wal_s3_bucket?:                    string @go(WALES3Bucket)
	aws_region?:                       string @go(AWSRegion)
	wal_gs_bucket?:                    string @go(WALGSBucket)
	gcp_credentials?:                  string @go(GCPCredentials)
	wal_az_storage_account?:           string @go(WALAZStorageAccount)
	log_s3_bucket?:                    string @go(LogS3Bucket)
	kube_iam_role?:                    string @go(KubeIAMRole)
	additional_secret_mount?:          string @go(AdditionalSecretMount)
	additional_secret_mount_path:      string @go(AdditionalSecretMountPath)
	enable_ebs_gp3_migration:          bool   @go(EnableEBSGp3Migration)
	enable_ebs_gp3_migration_max_size: int64  @go(EnableEBSGp3MigrationMaxSize)
}

// OperatorDebugConfiguration defines options for the debug mode
#OperatorDebugConfiguration: {
	debug_logging?:          bool @go(DebugLogging)
	enable_database_access?: bool @go(EnableDBAccess)
}

// TeamsAPIConfiguration defines the configuration of TeamsAPI
#TeamsAPIConfiguration: {
	enable_teams_api?: bool   @go(EnableTeamsAPI)
	teams_api_url?:    string @go(TeamsAPIUrl)
	team_api_role_configuration?: {[string]: string} @go(TeamAPIRoleConfiguration,map[string]string)
	enable_team_superuser?:       bool   @go(EnableTeamSuperuser)
	enable_admin_role_for_users?: bool   @go(EnableAdminRoleForUsers)
	team_admin_role?:             string @go(TeamAdminRole)
	pam_role_name?:               string @go(PamRoleName)
	pam_configuration?:           string @go(PamConfiguration)
	protected_role_names?: [...string] @go(ProtectedRoles,[]string)
	postgres_superuser_teams?: [...string] @go(PostgresSuperuserTeams,[]string)
	enable_postgres_team_crd?:            bool   @go(EnablePostgresTeamCRD)
	enable_postgres_team_crd_superusers?: bool   @go(EnablePostgresTeamCRDSuperusers)
	enable_team_member_deprecation?:      bool   @go(EnableTeamMemberDeprecation)
	role_deletion_suffix?:                string @go(RoleDeletionSuffix)
}

// LoggingRESTAPIConfiguration defines Logging API conf
#LoggingRESTAPIConfiguration: {
	api_port?:                int @go(APIPort)
	ring_log_lines?:          int @go(RingLogLines)
	cluster_history_entries?: int @go(ClusterHistoryEntries)
}

// ScalyrConfiguration defines the configuration for ScalyrAPI
#ScalyrConfiguration: {
	scalyr_api_key?:        string @go(ScalyrAPIKey)
	scalyr_image?:          string @go(ScalyrImage)
	scalyr_server_url?:     string @go(ScalyrServerURL)
	scalyr_cpu_request?:    string @go(ScalyrCPURequest)
	scalyr_memory_request?: string @go(ScalyrMemoryRequest)
	scalyr_cpu_limit?:      string @go(ScalyrCPULimit)
	scalyr_memory_limit?:   string @go(ScalyrMemoryLimit)
}

// ConnectionPoolerConfiguration defines default configuration for connection pooler
#ConnectionPoolerConfiguration: {
	connection_pooler_number_of_instances?:    null | int32 @go(NumberOfInstances,*int32)
	connection_pooler_schema?:                 string       @go(Schema)
	connection_pooler_user?:                   string       @go(User)
	connection_pooler_image?:                  string       @go(Image)
	connection_pooler_mode?:                   string       @go(Mode)
	connection_pooler_max_db_connections?:     null | int32 @go(MaxDBConnections,*int32)
	connection_pooler_default_cpu_request?:    string       @go(DefaultCPURequest)
	connection_pooler_default_memory_request?: string       @go(DefaultMemoryRequest)
	connection_pooler_default_cpu_limit?:      string       @go(DefaultCPULimit)
	connection_pooler_default_memory_limit?:   string       @go(DefaultMemoryLimit)
}

// OperatorLogicalBackupConfiguration defines configuration for logical backup
#OperatorLogicalBackupConfiguration: {
	logical_backup_schedule?:                       string @go(Schedule)
	logical_backup_docker_image?:                   string @go(DockerImage)
	logical_backup_provider?:                       string @go(BackupProvider)
	logical_backup_azure_storage_account_name?:     string @go(AzureStorageAccountName)
	logical_backup_azure_storage_container?:        string @go(AzureStorageContainer)
	logical_backup_azure_storage_account_key?:      string @go(AzureStorageAccountKey)
	logical_backup_s3_bucket?:                      string @go(S3Bucket)
	logical_backup_s3_region?:                      string @go(S3Region)
	logical_backup_s3_endpoint?:                    string @go(S3Endpoint)
	logical_backup_s3_access_key_id?:               string @go(S3AccessKeyID)
	logical_backup_s3_secret_access_key?:           string @go(S3SecretAccessKey)
	logical_backup_s3_sse?:                         string @go(S3SSE)
	logical_backup_s3_retention_time?:              string @go(RetentionTime)
	logical_backup_google_application_credentials?: string @go(GoogleApplicationCredentials)
	logical_backup_job_prefix?:                     string @go(JobPrefix)
	logical_backup_cpu_request?:                    string @go(CPURequest)
	logical_backup_memory_request?:                 string @go(MemoryRequest)
	logical_backup_cpu_limit?:                      string @go(CPULimit)
	logical_backup_memory_limit?:                   string @go(MemoryLimit)
}

// PatroniConfiguration defines configuration for Patroni
#PatroniConfiguration: {
	enable_patroni_failsafe_mode?: null | bool @go(FailsafeMode,*bool)
}

// OperatorConfigurationData defines the operation config
#OperatorConfigurationData: {
	enable_crd_registration?: null | bool @go(EnableCRDRegistration,*bool)
	enable_crd_validation?:   null | bool @go(EnableCRDValidation,*bool)
	crd_categories?: [...string] @go(CRDCategories,[]string)
	enable_lazy_spilo_upgrade?:         bool        @go(EnableLazySpiloUpgrade)
	enable_pgversion_env_var?:          bool        @go(EnablePgVersionEnvVar)
	enable_spilo_wal_path_compat?:      bool        @go(EnableSpiloWalPathCompat)
	enable_team_id_clustername_prefix?: bool        @go(EnableTeamIdClusternamePrefix)
	etcd_host?:                         string      @go(EtcdHost)
	kubernetes_use_configmaps?:         bool        @go(KubernetesUseConfigMaps)
	docker_image?:                      string      @go(DockerImage)
	workers?:                           uint32      @go(Workers)
	resync_period?:                     #Duration   @go(ResyncPeriod)
	repair_period?:                     #Duration   @go(RepairPeriod)
	set_memory_request_to_limit?:       bool        @go(SetMemoryRequestToLimit)
	enable_shm_volume?:                 null | bool @go(ShmVolume,*bool)
	sidecar_docker_images?: {[string]: string} @go(SidecarImages,map[string]string)
	sidecars?: [...v1.#Container] @go(SidecarContainers,[]v1.Container)
	users:                                  #PostgresUsersConfiguration         @go(PostgresUsersConfiguration)
	major_version_upgrade:                  #MajorVersionUpgradeConfiguration   @go(MajorVersionUpgrade)
	kubernetes:                             #KubernetesMetaConfiguration        @go(Kubernetes)
	postgres_pod_resources:                 #PostgresPodResourcesDefaults       @go(PostgresPodResources)
	timeouts:                               #OperatorTimeouts                   @go(Timeouts)
	load_balancer:                          #LoadBalancerConfiguration          @go(LoadBalancer)
	aws_or_gcp:                             #AWSGCPConfiguration                @go(AWSGCP)
	debug:                                  #OperatorDebugConfiguration         @go(OperatorDebug)
	teams_api:                              #TeamsAPIConfiguration              @go(TeamsAPI)
	logging_rest_api:                       #LoggingRESTAPIConfiguration        @go(LoggingRESTAPI)
	scalyr:                                 #ScalyrConfiguration                @go(Scalyr)
	logical_backup:                         #OperatorLogicalBackupConfiguration @go(LogicalBackup)
	connection_pooler:                      #ConnectionPoolerConfiguration      @go(ConnectionPooler)
	patroni:                                #PatroniConfiguration               @go(Patroni)
	min_instances?:                         int32                               @go(MinInstances)
	max_instances?:                         int32                               @go(MaxInstances)
	ignore_instance_limits_annotation_key?: string                              @go(IgnoreInstanceLimitsAnnotationKey)
}

// Duration shortens this frequently used name
#Duration: _
