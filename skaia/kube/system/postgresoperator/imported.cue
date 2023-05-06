package postgresoperator

resources: {
	clusterrolebindings: "postgres-operator": "postgres-operator": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			name:      "postgres-operator"
			namespace: "postgres-operator"
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "postgres-operator"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "postgres-operator"
			namespace: "postgres-operator"
		}]
	}
	clusterroles: "postgres-operator": {
		"postgres-operator": {
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name:      "postgres-operator"
				namespace: "postgres-operator"
			}
			rules: [{
				// all verbs allowed for custom operator resources
				apiGroups: [
					"acid.zalan.do",
				]
				resources: [
					"postgresqls",
					"postgresqls/status",
					"operatorconfigurations",
				]
				verbs: [
					"create",
					"delete",
					"deletecollection",
					"get",
					"list",
					"patch",
					"update",
					"watch",
				]
			}, {
				// operator only reads PostgresTeams
				apiGroups: [
					"acid.zalan.do",
				]
				resources: [
					"postgresteams",
				]
				verbs: [
					"get",
					"list",
					"watch",
				]
			}, {
				// all verbs allowed for event streams (Zalando-internal feature)
				// - apiGroups:
				//   - zalando.org
				//   resources:
				//   - fabriceventstreams
				//   verbs:
				//   - create
				//   - delete
				//   - deletecollection
				//   - get
				//   - list
				//   - patch
				//   - update
				//   - watch
				// to create or get/update CRDs when starting up
				apiGroups: [
					"apiextensions.k8s.io",
				]
				resources: [
					"customresourcedefinitions",
				]
				verbs: [
					"create",
					"get",
					"patch",
					"update",
				]
			}, {
				// to read configuration from ConfigMaps
				apiGroups: [
					"",
				]
				resources: [
					"configmaps",
				]
				verbs: [
					"get",
				]
			}, {
				// to send events to the CRs
				apiGroups: [
					"",
				]
				resources: [
					"events",
				]
				verbs: [
					"create",
					"get",
					"list",
					"patch",
					"update",
					"watch",
				]
			}, {
				// to manage endpoints which are also used by Patroni
				apiGroups: [
					"",
				]
				resources: [
					"endpoints",
				]
				verbs: [
					"create",
					"delete",
					"deletecollection",
					"get",
					"list",
					"patch",
					"update",
					"watch",
				]
			}, {
				// to CRUD secrets for database access
				apiGroups: [
					"",
				]
				resources: [
					"secrets",
				]
				verbs: [
					"create",
					"delete",
					"get",
					"update",
				]
			}, {
				// to check nodes for node readiness label
				apiGroups: [
					"",
				]
				resources: [
					"nodes",
				]
				verbs: [
					"get",
					"list",
					"watch",
				]
			}, {
				// to read or delete existing PVCs. Creation via StatefulSet
				apiGroups: [
					"",
				]
				resources: [
					"persistentvolumeclaims",
				]
				verbs: [
					"delete",
					"get",
					"list",
					"patch",
					"update",
				]
			}, {
				// to read existing PVs. Creation should be done via dynamic provisioning
				apiGroups: [
					"",
				]
				resources: [
					"persistentvolumes",
				]
				verbs: [
					"get",
					"list",
					"update",
				]
			}, {
				// only for resizing AWS volumes
				// to watch Spilo pods and do rolling updates. Creation via StatefulSet
				apiGroups: [
					"",
				]
				resources: [
					"pods",
				]
				verbs: [
					"delete",
					"get",
					"list",
					"patch",
					"update",
					"watch",
				]
			}, {
				// to resize the filesystem in Spilo pods when increasing volume size
				apiGroups: [
					"",
				]
				resources: [
					"pods/exec",
				]
				verbs: [
					"create",
				]
			}, {
				// to CRUD services to point to Postgres cluster instances
				apiGroups: [
					"",
				]
				resources: [
					"services",
				]
				verbs: [
					"create",
					"delete",
					"get",
					"patch",
					"update",
				]
			}, {
				// to CRUD the StatefulSet which controls the Postgres cluster instances
				apiGroups: [
					"apps",
				]
				resources: [
					"statefulsets",
					"deployments",
				]
				verbs: [
					"create",
					"delete",
					"get",
					"list",
					"patch",
				]
			}, {
				// to CRUD cron jobs for logical backups
				apiGroups: [
					"batch",
				]
				resources: [
					"cronjobs",
				]
				verbs: [
					"create",
					"delete",
					"get",
					"list",
					"patch",
					"update",
				]
			}, {
				// to get namespaces operator resources can run in
				apiGroups: [
					"",
				]
				resources: [
					"namespaces",
				]
				verbs: [
					"get",
				]
			}, {
				// to define PDBs. Update happens via delete/create
				apiGroups: [
					"policy",
				]
				resources: [
					"poddisruptionbudgets",
				]
				verbs: [
					"create",
					"delete",
					"get",
				]
			}, {
				// to create ServiceAccounts in each namespace the operator watches
				apiGroups: [
					"",
				]
				resources: [
					"serviceaccounts",
				]
				verbs: [
					"get",
					"create",
				]
			}, {
				// to create role bindings to the postgres-pod service account
				apiGroups: [
					"rbac.authorization.k8s.io",
				]
				resources: [
					"rolebindings",
				]
				verbs: [
					"get",
					"create",
				]
			}]
		}
		// to grant privilege to run privileged pods (not needed by default)
		//- apiGroups:
		//  - extensions
		//  resources:
		//  - podsecuritypolicies
		//  resourceNames:
		//  - privileged
		//  verbs:
		//  - use

		"postgres-pod": {
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name:      "postgres-pod"
				namespace: "postgres-operator"
			}
			rules: [{
				// Patroni needs to watch and manage endpoints
				apiGroups: [
					"",
				]
				resources: [
					"endpoints",
				]
				verbs: [
					"create",
					"delete",
					"deletecollection",
					"get",
					"list",
					"patch",
					"update",
					"watch",
				]
			}, {
				// Patroni needs to watch pods
				apiGroups: [
					"",
				]
				resources: [
					"pods",
				]
				verbs: [
					"get",
					"list",
					"patch",
					"update",
					"watch",
				]
			}, {
				// to let Patroni create a headless service
				apiGroups: [
					"",
				]
				resources: [
					"services",
				]
				verbs: [
					"create",
				]
			}]
		}
	}
	// to grant privilege to run privileged pods (not needed by default)
	//- apiGroups:
	//  - extensions
	//  resources:
	//  - podsecuritypolicies
	//  resourceNames:
	//  - privileged
	//  verbs:
	//  - use
	configmaps: {
		"postgres-operator": "postgres-operator": {
			apiVersion: "v1"
			kind:       "ConfigMap"
			metadata: {
				name:      "postgres-operator"
				namespace: "postgres-operator"
			}
			data: {
				// additional_owner_roles: "cron_admin"
				// additional_pod_capabilities: "SYS_NICE"
				// additional_secret_mount: "some-secret-name"
				// additional_secret_mount_path: "/some/dir"
				api_port:                "8080"
				aws_region:              "eu-central-1"
				cluster_domain:          "kube.skaia"
				cluster_history_entries: "1000"
				cluster_labels:          "application:spilo"
				cluster_name_label:      "cluster-name"
				// connection_pooler_default_cpu_limit: "1"
				// connection_pooler_default_cpu_request: "500m"
				// connection_pooler_default_memory_limit: 100Mi
				// connection_pooler_default_memory_request: 100Mi
				connection_pooler_image: "registry.opensource.zalan.do/acid/pgbouncer:master-27"
				// connection_pooler_max_db_connections: 60
				// connection_pooler_mode: "transaction"
				// connection_pooler_number_of_instances: 2
				// connection_pooler_schema: "pooler"
				// connection_pooler_user: "pooler"
				crd_categories: "all"
				// custom_service_annotations: "keyx:valuez,keya:valuea"
				// custom_pod_annotations: "keya:valuea,keyb:valueb"
				db_hosted_zone: "db.example.com"
				debug_logging:  "true"
				// default_cpu_limit: "1"
				// default_cpu_request: 100m
				// default_memory_limit: 500Mi
				// default_memory_request: 100Mi
				// delete_annotation_date_key: delete-date
				// delete_annotation_name_key: delete-clustername
				docker_image: "ghcr.io/zalando/spilo-15:3.0-p1"
				// downscaler_annotations: "deployment-time,downscaler/*"
				// enable_admin_role_for_users: "true"
				// enable_crd_registration: "true"
				// enable_cross_namespace_secret: "false"
				// enable_database_access: "true"
				enable_ebs_gp3_migration: "false"
				// enable_ebs_gp3_migration_max_size: "1000"
				// enable_init_containers: "true"
				// enable_lazy_spilo_upgrade: "false"
				enable_master_load_balancer:        "false"
				enable_master_pooler_load_balancer: "false"
				enable_password_rotation:           "false"
				enable_patroni_failsafe_mode:       "false"
				enable_pgversion_env_var:           "true"
				// enable_pod_antiaffinity: "false"
				// enable_pod_disruption_budget: "true"
				// enable_postgres_team_crd: "false"
				// enable_postgres_team_crd_superusers: "false"
				enable_readiness_probe:              "false"
				enable_replica_load_balancer:        "false"
				enable_replica_pooler_load_balancer: "false"
				// enable_shm_volume: "true"
				// enable_sidecars: "true"
				enable_spilo_wal_path_compat:      "true"
				enable_team_id_clustername_prefix: "false"
				enable_team_member_deprecation:    "false"
				// enable_team_superuser: "false"
				enable_teams_api: "false"
				// etcd_host: ""
				external_traffic_policy: "Cluster"
				// gcp_credentials: ""
				// ignored_annotations: ""
				// infrastructure_roles_secret_name: "postgresql-infrastructure-roles"
				// infrastructure_roles_secrets: "secretname:monitoring-roles,userkey:user,passwordkey:password,rolekey:inrole"
				// ignore_instance_limits_annotation_key: ""
				// inherited_annotations: owned-by
				// inherited_labels: application,environment
				// kube_iam_role: ""
				// kubernetes_use_configmaps: "false"
				// log_s3_bucket: ""
				// logical_backup_azure_storage_account_name: ""
				// logical_backup_azure_storage_container: ""
				// logical_backup_azure_storage_account_key: ""
				// logical_backup_cpu_limit: ""
				// logical_backup_cpu_request: ""
				logical_backup_docker_image: "registry.opensource.zalan.do/acid/logical-backup:v1.10.0"
				// logical_backup_google_application_credentials: ""
				logical_backup_job_prefix: "logical-backup-"
				// logical_backup_memory_limit: ""
				// logical_backup_memory_request: ""
				logical_backup_provider: "s3"
				// logical_backup_s3_access_key_id: ""
				logical_backup_s3_bucket: "my-bucket-url"
				// logical_backup_s3_region: ""
				// logical_backup_s3_endpoint: ""
				// logical_backup_s3_secret_access_key: ""
				logical_backup_s3_sse: "AES256"
				// logical_backup_s3_retention_time: ""
				logical_backup_schedule:    "30 00 * * *"
				major_version_upgrade_mode: "manual"
				// major_version_upgrade_team_allow_list: ""
				master_dns_name_format: "{cluster}.{namespace}.{hostedzone}"
				// master_legacy_dns_name_format: "{cluster}.{team}.{hostedzone}"
				// master_pod_move_timeout: 20m
				// max_instances: "-1"
				// min_instances: "-1"
				// max_cpu_request: "1"
				// max_memory_request: 4Gi
				// min_cpu_limit: 250m
				// min_memory_limit: 250Mi
				// minimal_major_version: "11"
				// node_readiness_label: "status:ready"
				// node_readiness_label_merge: "OR"
				// oauth_token_secret_name: postgresql-operator
				// pam_configuration: |
				//  https://info.example.com/oauth2/tokeninfo?access_token= uid realm=/employees
				// pam_role_name: zalandos
				patroni_api_check_interval: "1s"
				patroni_api_check_timeout:  "5s"
				// password_rotation_interval: "90"
				// password_rotation_user_retention: "180"
				pdb_name_format: "postgres-{cluster}-pdb"
				// pod_antiaffinity_preferred_during_scheduling: "false"
				// pod_antiaffinity_topology_key: "kubernetes.io/hostname"
				pod_deletion_wait_timeout: "10m"
				// pod_environment_configmap: "default/my-custom-config"
				// pod_environment_secret: "my-custom-secret"
				pod_label_wait_timeout: "10m"
				pod_management_policy:  "ordered_ready"
				// pod_priority_class_name: "postgres-pod-priority"
				pod_role_label: "spilo-role"
				// pod_service_account_definition: ""
				pod_service_account_name: "postgres-pod"
				// pod_service_account_role_binding_definition: ""
				pod_terminate_grace_period: "5m"
				// postgres_superuser_teams: "postgres_superusers"
				// protected_role_names: "admin,cron_admin"
				ready_wait_interval:     "3s"
				ready_wait_timeout:      "30s"
				repair_period:           "5m"
				replica_dns_name_format: "{cluster}-repl.{namespace}.{hostedzone}"
				// replica_legacy_dns_name_format: "{cluster}-repl.{team}.{hostedzone}"
				replication_username:         "standby"
				resource_check_interval:      "3s"
				resource_check_timeout:       "10m"
				resync_period:                "30m"
				ring_log_lines:               "100"
				role_deletion_suffix:         "_deleted"
				secret_name_template:         "{username}.{cluster}.credentials.{tprkind}.{tprgroup}"
				share_pgsocket_with_sidecars: "false"
				// sidecar_docker_images: ""
				// set_memory_request_to_limit: "false"
				spilo_allow_privilege_escalation: "true"
				// spilo_runasuser: 101
				// spilo_runasgroup: 103
				// spilo_fsgroup: 103
				spilo_privileged:    "false"
				storage_resize_mode: "pvc"
				super_username:      "postgres"
				// target_major_version: "15"
				// team_admin_role: "admin"
				// team_api_role_configuration: "log_statement:all"
				// teams_api_url: http://fake-teams-api.default.svc.cluster.local
				// toleration: "key:db-only,operator:Exists,effect:NoSchedule"
				// wal_az_storage_account: ""
				// wal_gs_bucket: ""
				// wal_s3_bucket: ""
				watched_namespace: "*" // listen to all namespaces
				workers:           "8"
			}
		}
	}
	deployments: "postgres-operator": "postgres-operator": {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			name: "postgres-operator"
			labels: application: "postgres-operator"
			namespace: "postgres-operator"
		}
		spec: {
			replicas: 1
			strategy: type: "Recreate"
			selector: matchLabels: name: "postgres-operator"
			template: {
				metadata: labels: name: "postgres-operator"
				spec: {
					serviceAccountName: "postgres-operator"
					containers: [{
						name:            "postgres-operator"
						image:           "registry.opensource.zalan.do/acid/postgres-operator:v1.10.0"
						imagePullPolicy: "IfNotPresent"
						resources: requests: {
							cpu:    "100m"
							memory: "250Mi"
						}
						securityContext: {
							runAsUser:                1000
							runAsNonRoot:             true
							readOnlyRootFilesystem:   true
							allowPrivilegeEscalation: false
						}
						env: [{
							// provided additional ENV vars can overwrite individual config map entries
							name:  "CONFIG_MAP_NAME"
							value: "postgres-operator"
						}]
					}]
				}
			}
		}
	}
	// In order to use the CRD OperatorConfiguration instead, uncomment these lines and comment out the two lines above
	// - name: POSTGRES_OPERATOR_CONFIGURATION_OBJECT
	//  value: postgresql-operator-default-configuration
	// Define an ID to isolate controllers from each other
	// - name: CONTROLLER_ID
	//   value: "second-operator"
	serviceaccounts: {
		"postgres-operator": "postgres-operator": {
			apiVersion: "v1"
			kind:       "ServiceAccount"
			metadata: {
				name:      "postgres-operator"
				namespace: "postgres-operator"
			}
		}
	}
	services: "postgres-operator": "postgres-operator": {
		apiVersion: "v1"
		kind:       "Service"
		metadata: {
			name:      "postgres-operator"
			namespace: "postgres-operator"
		}
		spec: {
			type: "ClusterIP"
			ports: [{
				port:       8080
				protocol:   "TCP"
				targetPort: 8080
			}]
			selector: name: "postgres-operator"
		}
	}
}
