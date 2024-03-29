package schema

import (
	acidzalandov1 "github.com/zalando/postgres-operator/pkg/apis/acid.zalan.do/v1"
	k8sadmissionregistrationv1 "k8s.io/api/admissionregistration/v1"
	k8sapiextensionsv1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
	k8sapiregistrationv1 "k8s.io/kube-aggregator/pkg/apis/apiregistration/v1"
	k8sappsv1 "k8s.io/api/apps/v1"
	k8sbatchv1 "k8s.io/api/batch/v1"
	k8scorev1 "k8s.io/api/core/v1"
	k8snetworkingv1 "k8s.io/api/networking/v1"
	k8spolicyv1 "k8s.io/api/policy/v1"
	k8srbacv1 "k8s.io/api/rbac/v1"
	k8sschedulingv1 "k8s.io/api/scheduling/v1"
	k8sstoragev1 "k8s.io/api/storage/v1"
	objectbucketv1alpha1 "github.com/kube-object-storage/lib-bucket-provisioner/pkg/apis/objectbucket.io/v1alpha1"
	prometheusv1 "github.com/prometheus-operator/prometheus-operator/pkg/apis/monitoring/v1"
	rookcephv1 "github.com/rook/rook/pkg/apis/ceph.rook.io/v1"
	stashv1alpha1 "stash.appscode.dev/apimachinery/apis/stash/v1alpha1"
	stashv1beta1 "stash.appscode.dev/apimachinery/apis/stash/v1beta1"
)

resources: close({
	alertmanagers: [Namespace=string]: [Name=string]: prometheusv1.#Alertmanager & {
		apiVersion: "monitoring.coreos.com/v1"
		kind:       "Alertmanager"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	apiservices: [""]: [Name=string]: k8sapiregistrationv1.#APIService & {
		apiVersion: "apiregistration.k8s.io/v1"
		kind:       "APIService"
		metadata: name: Name
	}
	backupconfigurations: [Namespace=string]: [Name=string]: stashv1beta1.#BackupConfiguration & {
		apiVersion: "stash.appscode.com/v1beta1"
		kind:       "BackupConfiguration"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	backuprepositories: [Namespace=string]: [Name=string]: stashv1alpha1.#Repository & {
		apiVersion: "stash.appscode.com/v1alpha1"
		kind:       "Repository"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	bgpconfigurations: [""]: [Name=string]: close({
		apiVersion: "crd.projectcalico.org/v1"
		kind:       "BGPConfiguration"
		metadata: name: Name
		spec: close({
			logSeverityScreen?:     "Debug" | "Info" | "Warning" | "Error" | "Fatal"
			nodeToNodeMeshEnabled?: bool
			asNumber?:              string | uint32
			serviceClusterIPs?: [...{cidr: string}]
			serviceExternalIPs?: [...{cidr: string}]
			serviceLoadBalancerIPs?: [...{cidr: string}]
			listenPort?:             uint16
			bindMode?:               "Node" | "NodeIP"
			communities?:            _
			prefixAdvertisements?:   _
			nodeMeshPassword?:       _
			nodeMeshMaxRestartTime?: string
		})
	})
	bgppeers: [""]: [Name=string]: close({
		apiVersion: "crd.projectcalico.org/v1"
		kind:       "BGPPeer"
		metadata: name: Name
		spec: close({
			node?:                string
			peerIP?:              string
			asNumber?:            string | uint32
			nodeSelector?:        string
			peerSelector?:        string
			keepOriginalNextHop?: bool
			password?:            close({
				secretKeyRef?: close({
					name?: string
					key?:  string
				})
			})
			sourceAddress?:            "UseNodeIP" | "None"
			maxRestartTime?:           string
			numAllowedLocalASNumbers?: uint
		})
	})
	caliconodestatuses: [""]: [Name=string]: close({
		apiVersion: "crd.projectcalico.org/v1"
		kind:       "CalicoNodeStatus"
		metadata: name: Name
		spec: close({
			classes?: [...string]
			node?:                string
			updatePeriodSeconds?: uint
		})
	})
	cephblockpools: [Namespace=string]: [Name=string]: rookcephv1.#CephBlockPool & {
		apiVersion: "ceph.rook.io/v1"
		kind:       "CephBlockPool"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	cephclusters: [Namespace=string]: [Name=string]: rookcephv1.#CephCluster & {
		apiVersion: "ceph.rook.io/v1"
		kind:       "CephCluster"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	cephfilesystems: [Namespace=string]: [Name=string]: rookcephv1.#CephFilesystem & {
		apiVersion: "ceph.rook.io/v1"
		kind:       "CephFilesystem"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	cephobjectstores: [Namespace=string]: [Name=string]: rookcephv1.#CephObjectStore & {
		apiVersion: "ceph.rook.io/v1"
		kind:       "CephObjectStore"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	clusterrolebindings: [""]: [Name=string]: k8srbacv1.#ClusterRoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: name: Name
	}
	clusterroles: [""]: [Name=string]: k8srbacv1.#ClusterRole & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: name: Name
	}
	configmaps: [Namespace=string]: [Name=string]: k8scorev1.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	cronjobs: [Namespace=string]: [Name=string]: k8sbatchv1.#CronJob & {
		apiVersion: "batch/v1"
		kind:       "CronJob"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	customresourcedefinitions: [""]: [Name=string]: k8sapiextensionsv1.#CustomResourceDefinition & {
		apiVersion: "apiextensions.k8s.io/v1"
		kind:       "CustomResourceDefinition"
		metadata: name: Name
	}
	daemonsets: [Namespace=string]: [Name=string]: k8sappsv1.#DaemonSet & {
		apiVersion: "apps/v1"
		kind:       "DaemonSet"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	deployments: [Namespace=string]: [Name=string]: k8sappsv1.#Deployment & {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	ingressclasses: [""]: [Name=string]: k8snetworkingv1.#IngressClass & {
		apiVersion: "networking.k8s.io/v1"
		kind:       "IngressClass"
		metadata: name: Name
	}
	jobs: [Namespace=string]: [Name=string]: k8sbatchv1.#Job & {
		apiVersion: "batch/v1"
		kind:       "Job"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	mutatingwebhookconfigurations: [""]: [Name=string]: k8sadmissionregistrationv1.#MutatingWebhookConfiguration & {
		apiVersion: "admissionregistration.k8s.io/v1"
		kind:       "MutatingWebhookConfiguration"
		metadata: name: Name
	}
	namespaces: [""]: [Name=string]: k8scorev1.#Namespace & {
		apiVersion: "v1"
		kind:       "Namespace"
		metadata: name: Name
	}
	networkpolicies: [Namespace=string]: [Name=string]: k8snetworkingv1.#NetworkPolicy & {
		apiVersion: "networking.k8s.io/v1"
		kind:       "NetworkPolicy"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	nodes: [""]: [Name=string]: k8scorev1.#Node & {
		apiVersion: "v1"
		kind:       "Node"
		metadata: name: Name
	}
	objectbucketclaims: [Namespace=string]: [Name=string]: objectbucketv1alpha1.#ObjectBucketClaim & {
		apiVersion: "objectbucket.io/v1alpha1"
		kind:       "ObjectBucketClaim"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	persistentvolumeclaims: [Namespace=string]: [Name=string]: k8scorev1.#PersistentVolumeClaim & {
		apiVersion: "v1"
		kind:       "PersistentVolumeClaim"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	poddisruptionbudgets: [Namespace=string]: [Name=string]: k8spolicyv1.#PodDisruptionBudget & {
		apiVersion: "policy/v1"
		kind:       "PodDisruptionBudget"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	postgresqls: [Namespace=string]: [Name=string]: acidzalandov1.#Postgresql & {
		apiVersion: "acid.zalan.do/v1"
		kind: "postgresql"
		metadata: name: Name
		metadata: namespace: Namespace
	}
	priorityclasses: [""]: [Name=string]: k8sschedulingv1.#PriorityClass & {
		apiVersion: "scheduling.k8s.io/v1"
		kind:       "PriorityClass"
		metadata: name: Name
	}
	prometheuses: [Namespace=string]: [Name=string]: prometheusv1.#Prometheus & {
		apiVersion: "monitoring.coreos.com/v1"
		kind:       "Prometheus"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	prometheusrules: [Namespace=string]: [Name=string]: prometheusv1.#PrometheusRule & {
		apiVersion: "monitoring.coreos.com/v1"
		kind:       "PrometheusRule"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	rolebindings: [Namespace=string]: [Name=string]: k8srbacv1.#RoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	roles: [Namespace=string]: [Name=string]: k8srbacv1.#Role & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "Role"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	secrets: [Namespace=string]: [Name=string]: k8scorev1.#Secret & {
		apiVersion: "v1"
		kind:       "Secret"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	serviceaccounts: [Namespace=string]: [Name=string]: k8scorev1.#ServiceAccount & {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	servicemonitors: [Namespace=string]: [Name=string]: prometheusv1.#ServiceMonitor & {
		apiVersion: "monitoring.coreos.com/v1"
		kind:       "ServiceMonitor"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	services: [Namespace=string]: [Name=string]: k8scorev1.#Service & {
		apiVersion: "v1"
		kind:       "Service"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	statefulsets: [Namespace=string]: [Name=string]: k8sappsv1.#StatefulSet & {
		apiVersion: "apps/v1"
		kind:       "StatefulSet"
		metadata: name:      Name
		metadata: namespace: Namespace
	}
	storageclasses: [""]: [Name=string]: k8sstoragev1.#StorageClass & {
		apiVersion: "storage.k8s.io/v1"
		kind:       "StorageClass"
		metadata: name: Name
	}
	talosserviceaccounts: [Namespace=string]: [Name=string]: {
		apiVersion: "talos.dev/v1alpha1"
		kind:       "ServiceAccount"
		metadata: name:      Name
		metadata: namespace: Namespace
		spec: {
			roles: [...string]
		}
	}
	validatingwebhookconfigurations: [""]: [Name=string]: k8sadmissionregistrationv1.#ValidatingWebhookConfiguration & {
		apiVersion: "admissionregistration.k8s.io/v1"
		kind:       "ValidatingWebhookConfiguration"
		metadata: name: Name
	}
})
