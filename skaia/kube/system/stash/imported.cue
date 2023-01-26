package stash

resources: {
	apiservices: "": {
		"v1alpha1.admission.stash.appscode.com": {
			// Source: stash/charts/stash-community/templates/apiregistration.yaml
			apiVersion: "apiregistration.k8s.io/v1"
			kind:       "APIService"
			metadata: {
				name: "v1alpha1.admission.stash.appscode.com"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
			spec: {
				group:   "admission.stash.appscode.com"
				version: "v1alpha1"
				service: {
					namespace: "stash"
					name:      "stash"
				}
				caBundle:             "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lSQVB3Um9yZXBCWkZQdjJ0LzhFbWdJaWN3RFFZSktvWklodmNOQVFFTEJRQXcKRFRFTE1Ba0dBMVVFQXhNQ1kyRXdIaGNOTWpJeE1qTXdNREl4TkRJd1doY05Nekl4TWpJM01ESXhOREl3V2pBTgpNUXN3Q1FZRFZRUURFd0pqWVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTUpMCk1LaHdVZ0M3dVlZTHRFYmhCdWluOGE4KzZxell0TWtnMXkrVExURkNKL2RuOFpBUVh6cDRRcFdieGUvRWtNVS8KNVU4WCtCYUl0dW4wTmhQakxReEpaeE1yMHB4azhna21XaVMzekcvcXptbTVNVm5NT0pXVWlzcUQ2TkNzNS9RQwovM0ZKREZSc0ZDT0dweUpMelBQY2ljbWJPRTlraFlXK0tjSWpCVUlDbVFIQ0N4RU9qbEI5dlEvSGRqNGxzdllUCmprRE5sN1RzRnpGYXJhc2ZqbGJmUEUzUVhlSUM3ejcvc0Uvc2FOMmRYSVJHVm5objRmTG11T1dOWXJ1czVFelkKdGtBY0VnZGZ4TzNsbUl4RElVUUJQa3FxbWp2eHpLSU9VRFFaTTczcFMwN2QrSzZiU1QxMGpQOStxYXI3enFTaApYbUlpN1VJWktiOTRCNlZFbGdVQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJTTVZCMjJlRzZQc2J3QURvbE44UG5pbkpSdmdEQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFEQkZPb2puZApITUJpcHkzTEpDWS82VEVva1pKNElSZ3dlWEZBTVkzWEtRS2tyT1dBbWNFcDlrc3V6RDZMMjRCTWtldXh6d01NCk9VYWx4U1VRVFliTFZZSzF0dEpEdlA5b2ZJVWVlTHJVYUd6OWZoOGVhUXFWVXJuNzdXYk9kYVlKNXROZk1xRE8KcFVaV1R0QWtyNFRpdi9MaGNpRzBCQ0JFaHlJWXdBUk0rNHpDZ3pwYlA2RG05b3VXRXliaGYySmdNbVFvdDBPbwppcGxXbmIyT25EYzlmRzltR1Q3dGFvNHFKaTRqWEg3T1JmcWwrRXR4cWhJOHpFVWpzeCttYW5tQUVPVUJUOURJCjdhaHZOaVM5YTVWZXhKaTg4ZVg2NjBQcjN2TEdTQVhDbUkvcXFkUk1WMFR6cWp1RjFoeHRsdWp4bjJRRmtpVlYKTnE4dWRFZU5hb1pIU2c9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
				groupPriorityMinimum: 10000
				versionPriority:      15
			}
		}
		"v1alpha1.repositories.stash.appscode.com": {
			// Source: stash/charts/stash-community/templates/apiregistration.yaml
			apiVersion: "apiregistration.k8s.io/v1"
			kind:       "APIService"
			metadata: {
				name: "v1alpha1.repositories.stash.appscode.com"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
			spec: {
				group:   "repositories.stash.appscode.com"
				version: "v1alpha1"
				service: {
					namespace: "stash"
					name:      "stash"
				}
				caBundle:             "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lSQVB3Um9yZXBCWkZQdjJ0LzhFbWdJaWN3RFFZSktvWklodmNOQVFFTEJRQXcKRFRFTE1Ba0dBMVVFQXhNQ1kyRXdIaGNOTWpJeE1qTXdNREl4TkRJd1doY05Nekl4TWpJM01ESXhOREl3V2pBTgpNUXN3Q1FZRFZRUURFd0pqWVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTUpMCk1LaHdVZ0M3dVlZTHRFYmhCdWluOGE4KzZxell0TWtnMXkrVExURkNKL2RuOFpBUVh6cDRRcFdieGUvRWtNVS8KNVU4WCtCYUl0dW4wTmhQakxReEpaeE1yMHB4azhna21XaVMzekcvcXptbTVNVm5NT0pXVWlzcUQ2TkNzNS9RQwovM0ZKREZSc0ZDT0dweUpMelBQY2ljbWJPRTlraFlXK0tjSWpCVUlDbVFIQ0N4RU9qbEI5dlEvSGRqNGxzdllUCmprRE5sN1RzRnpGYXJhc2ZqbGJmUEUzUVhlSUM3ejcvc0Uvc2FOMmRYSVJHVm5objRmTG11T1dOWXJ1czVFelkKdGtBY0VnZGZ4TzNsbUl4RElVUUJQa3FxbWp2eHpLSU9VRFFaTTczcFMwN2QrSzZiU1QxMGpQOStxYXI3enFTaApYbUlpN1VJWktiOTRCNlZFbGdVQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJTTVZCMjJlRzZQc2J3QURvbE44UG5pbkpSdmdEQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFEQkZPb2puZApITUJpcHkzTEpDWS82VEVva1pKNElSZ3dlWEZBTVkzWEtRS2tyT1dBbWNFcDlrc3V6RDZMMjRCTWtldXh6d01NCk9VYWx4U1VRVFliTFZZSzF0dEpEdlA5b2ZJVWVlTHJVYUd6OWZoOGVhUXFWVXJuNzdXYk9kYVlKNXROZk1xRE8KcFVaV1R0QWtyNFRpdi9MaGNpRzBCQ0JFaHlJWXdBUk0rNHpDZ3pwYlA2RG05b3VXRXliaGYySmdNbVFvdDBPbwppcGxXbmIyT25EYzlmRzltR1Q3dGFvNHFKaTRqWEg3T1JmcWwrRXR4cWhJOHpFVWpzeCttYW5tQUVPVUJUOURJCjdhaHZOaVM5YTVWZXhKaTg4ZVg2NjBQcjN2TEdTQVhDbUkvcXFkUk1WMFR6cWp1RjFoeHRsdWp4bjJRRmtpVlYKTnE4dWRFZU5hb1pIU2c9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
				groupPriorityMinimum: 10000
				versionPriority:      15
			}
		}
		"v1beta1.admission.stash.appscode.com": {
			// Source: stash/charts/stash-community/templates/apiregistration.yaml
			apiVersion: "apiregistration.k8s.io/v1"
			kind:       "APIService"
			metadata: {
				name: "v1beta1.admission.stash.appscode.com"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
			spec: {
				group:   "admission.stash.appscode.com"
				version: "v1beta1"
				service: {
					namespace: "stash"
					name:      "stash"
				}
				caBundle:             "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lSQVB3Um9yZXBCWkZQdjJ0LzhFbWdJaWN3RFFZSktvWklodmNOQVFFTEJRQXcKRFRFTE1Ba0dBMVVFQXhNQ1kyRXdIaGNOTWpJeE1qTXdNREl4TkRJd1doY05Nekl4TWpJM01ESXhOREl3V2pBTgpNUXN3Q1FZRFZRUURFd0pqWVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTUpMCk1LaHdVZ0M3dVlZTHRFYmhCdWluOGE4KzZxell0TWtnMXkrVExURkNKL2RuOFpBUVh6cDRRcFdieGUvRWtNVS8KNVU4WCtCYUl0dW4wTmhQakxReEpaeE1yMHB4azhna21XaVMzekcvcXptbTVNVm5NT0pXVWlzcUQ2TkNzNS9RQwovM0ZKREZSc0ZDT0dweUpMelBQY2ljbWJPRTlraFlXK0tjSWpCVUlDbVFIQ0N4RU9qbEI5dlEvSGRqNGxzdllUCmprRE5sN1RzRnpGYXJhc2ZqbGJmUEUzUVhlSUM3ejcvc0Uvc2FOMmRYSVJHVm5objRmTG11T1dOWXJ1czVFelkKdGtBY0VnZGZ4TzNsbUl4RElVUUJQa3FxbWp2eHpLSU9VRFFaTTczcFMwN2QrSzZiU1QxMGpQOStxYXI3enFTaApYbUlpN1VJWktiOTRCNlZFbGdVQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJTTVZCMjJlRzZQc2J3QURvbE44UG5pbkpSdmdEQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFEQkZPb2puZApITUJpcHkzTEpDWS82VEVva1pKNElSZ3dlWEZBTVkzWEtRS2tyT1dBbWNFcDlrc3V6RDZMMjRCTWtldXh6d01NCk9VYWx4U1VRVFliTFZZSzF0dEpEdlA5b2ZJVWVlTHJVYUd6OWZoOGVhUXFWVXJuNzdXYk9kYVlKNXROZk1xRE8KcFVaV1R0QWtyNFRpdi9MaGNpRzBCQ0JFaHlJWXdBUk0rNHpDZ3pwYlA2RG05b3VXRXliaGYySmdNbVFvdDBPbwppcGxXbmIyT25EYzlmRzltR1Q3dGFvNHFKaTRqWEg3T1JmcWwrRXR4cWhJOHpFVWpzeCttYW5tQUVPVUJUOURJCjdhaHZOaVM5YTVWZXhKaTg4ZVg2NjBQcjN2TEdTQVhDbUkvcXFkUk1WMFR6cWp1RjFoeHRsdWp4bjJRRmtpVlYKTnE4dWRFZU5hb1pIU2c9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
				groupPriorityMinimum: 10000
				versionPriority:      15
			}
		}
	}
	clusterrolebindings: "": {
		"appscode:stash:garbage-collector": {
			// Source: stash/charts/stash-community/templates/gerbage-collector-rbac.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRoleBinding"
			metadata: {
				name: "appscode:stash:garbage-collector"
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade"
					"helm.sh/hook-delete-policy": "before-hook-creation"
				}
			}
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "ClusterRole"
				name:     "appscode:stash:garbage-collector"
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      "generic-garbage-collector"
				namespace: "kube-system"
			}]
		}
		stash: {
			// Source: stash/charts/stash-community/templates/cluster-role-binding.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRoleBinding"
			metadata: {
				name: "stash"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "ClusterRole"
				name:     "stash"
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      "stash"
				namespace: "stash"
			}]
		}
		"stash-apiserver-auth-delegator": {
			// Source: stash/charts/stash-community/templates/apiregistration.yaml
			// to delegate authentication and authorization
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRoleBinding"
			metadata: {
				name: "stash-apiserver-auth-delegator"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
			roleRef: {
				kind:     "ClusterRole"
				apiGroup: "rbac.authorization.k8s.io"
				name:     "system:auth-delegator"
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      "stash"
				namespace: "stash"
			}]
		}
		"stash-cleaner": {
			// Source: stash/charts/stash-community/templates/cleaner/cluster_rolebinding.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRoleBinding"
			metadata: {
				name: "stash-cleaner"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
				annotations: {
					"helm.sh/hook":               "pre-delete"
					"helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
				}
			}
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "ClusterRole"
				name:     "stash-cleaner"
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      "stash-cleaner"
				namespace: "stash"
			}]
		}
		"stash-crd-installer": {
			// Source: stash/charts/stash-community/templates/crd-installer/cluster_rolebinding.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRoleBinding"
			metadata: {
				name: "stash-crd-installer"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade,pre-rollback"
					"helm.sh/hook-delete-policy": "before-hook-creation,hook-failed"
				}
			}
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "ClusterRole"
				name:     "stash-crd-installer"
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      "stash-crd-installer"
				namespace: "stash"
			}]
		}
		"stash-license-checker": {
			// Source: stash/charts/stash-community/templates/license-checker-cluster-role-binding.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRoleBinding"
			metadata: name: "stash-license-checker"
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "ClusterRole"
				name:     "appscode:license-checker"
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      "stash"
				namespace: "stash"
			}]
		}
		"stash-license-reader": {
			// Source: stash/charts/stash-community/templates/license-reader-cluster-role-binding.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRoleBinding"
			metadata: name: "stash-license-reader"
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "ClusterRole"
				name:     "appscode:license-reader"
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      "stash"
				namespace: "stash"
			}]
		}
	}
	clusterroles: "": {
		"appscode:license-checker": {
			// Source: stash/charts/stash-community/templates/license-checker-cluster-role.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name: "appscode:license-checker"
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade"
					"helm.sh/hook-delete-policy": "before-hook-creation"
				}
			}
			rules: [{
				// Get cluster id
				apiGroups: [
					"",
				]
				resources: [
					"namespaces",
				]
				verbs: ["get"]
			}, {
				// Issue license
				apiGroups: [
					"proxyserver.licenses.appscode.com",
				]
				resources: [
					"licenserequests",
				]
				verbs: ["create"]
			}, {
				// Detect workload/owner of operator pod
				apiGroups: [
					"",
				]
				resources: [
					"pods",
				]
				verbs: ["get"]
			}, {
				apiGroups: [
					"apps",
				]
				resources: [
					"deployments",
					"replicasets",
				]
				verbs: ["get"]
			}, {
				// Write events in case of license verification failure
				apiGroups: [
					"",
				]
				resources: [
					"events",
				]
				verbs: ["get", "list", "create", "patch"]
			}]
		}
		"appscode:license-reader": {
			// Source: stash/charts/stash-community/templates/license-reader-cluster-role.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name: "appscode:license-reader"
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade"
					"helm.sh/hook-delete-policy": "before-hook-creation"
				}
			}
			rules: [{
				// Detect license server endpoint for stash addons
				apiGroups: [
					"apiregistration.k8s.io",
				]
				resources: [
					"apiservices",
				]
				verbs: ["get"]
			}, {
				nonResourceURLs: [
					"/appscode/license",
				]
				verbs: ["get"]
			}]
		}
		"appscode:stash:edit": {
			// Source: stash/charts/stash-community/templates/user-roles.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name: "appscode:stash:edit"
				labels: {
					"rbac.authorization.k8s.io/aggregate-to-admin": "true"
					"rbac.authorization.k8s.io/aggregate-to-edit":  "true"
				}
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade"
					"helm.sh/hook-delete-policy": "before-hook-creation"
				}
			}
			rules: [{
				apiGroups: [
					"stash.appscode.com",
					"repositories.stash.appscode.com",
					"appcatalog.appscode.com",
				]
				resources: [
					"*",
				]
				verbs: ["*"]
			}]
		}
		"appscode:stash:garbage-collector": {
			// Source: stash/charts/stash-community/templates/gerbage-collector-rbac.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name: "appscode:stash:garbage-collector"
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade"
					"helm.sh/hook-delete-policy": "before-hook-creation"
				}
			}
			rules: [{
				apiGroups: [
					"policy",
				]
				verbs: ["use"]
				resources: [
					"podsecuritypolicies",
				]
			}]
		}
		"appscode:stash:view": {
			// Source: stash/charts/stash-community/templates/user-roles.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name: "appscode:stash:view"
				labels: "rbac.authorization.k8s.io/aggregate-to-view": "true"
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade"
					"helm.sh/hook-delete-policy": "before-hook-creation"
				}
			}
			rules: [{
				apiGroups: [
					"stash.appscode.com",
					"repositories.stash.appscode.com",
					"appcatalog.appscode.com",
				]
				resources: [
					"*",
				]
				verbs: ["get", "list", "watch"]
			}]
		}
		stash: {
			// Source: stash/charts/stash-community/templates/cluster-role.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name: "stash"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
			rules: [{
				apiGroups: [
					"apiextensions.k8s.io",
				]
				resources: [
					"customresourcedefinitions",
				]
				verbs: ["*"]
			}, {
				apiGroups: [
					"apiregistration.k8s.io",
				]
				resources: [
					"apiservices",
				]
				verbs: ["get", "patch", "delete"]
			}, {
				apiGroups: [
					"admissionregistration.k8s.io",
				]
				resources: [
					"mutatingwebhookconfigurations",
					"validatingwebhookconfigurations",
				]
				verbs: ["delete", "get", "list", "watch", "patch"]
			}, {
				apiGroups: [
					"stash.appscode.com",
				]
				resources: [
					"*",
				]
				verbs: ["*"]
			}, {
				apiGroups: [
					"appcatalog.appscode.com",
				]
				resources: [
					"*",
				]
				verbs: ["*"]
			}, {
				apiGroups: [
					"apps",
				]
				resources: [
					"daemonsets",
					"deployments",
					"statefulsets",
				]
				verbs: ["get", "list", "watch", "patch"]
			}, {
				apiGroups: [
					"batch",
				]
				resources: [
					"jobs",
					"cronjobs",
				]
				verbs: ["get", "list", "watch", "create", "delete", "patch"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"namespaces",
				]
				verbs: ["get", "list", "watch", "patch"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"configmaps",
				]
				verbs: ["create", "update", "get", "list", "watch", "delete"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"persistentvolumeclaims",
				]
				verbs: ["get", "list", "watch", "create", "patch"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"services",
					"endpoints",
				]
				verbs: ["get"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"secrets",
				]
				verbs: ["get", "list", "create", "patch"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"events",
				]
				verbs: ["get", "list", "create", "patch"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"nodes",
				]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"pods",
					"pods/exec",
				]
				verbs: ["get", "create", "list", "delete", "deletecollection"]
			}, {
				apiGroups: [
					"",
				]
				resources: [
					"serviceaccounts",
				]
				verbs: ["get", "create", "patch", "delete"]
			}, {
				apiGroups: [
					"rbac.authorization.k8s.io",
				]
				resources: [
					"clusterroles",
					"roles",
					"rolebindings",
					"clusterrolebindings",
				]
				verbs: ["get", "list", "create", "delete", "patch"]
			}, {
				apiGroups: [
					"apps.openshift.io",
				]
				resources: [
					"deploymentconfigs",
				]
				verbs: ["get", "list", "watch", "patch"]
			}, {
				apiGroups: [
					"snapshot.storage.k8s.io",
				]
				resources: [
					"volumesnapshots",
					"volumesnapshotcontents",
					"volumesnapshotclasses",
				]
				verbs: ["create", "get", "list", "watch", "patch", "delete"]
			}, {
				apiGroups: [
					"storage.k8s.io",
				]
				resources: [
					"storageclasses",
				]
				verbs: ["get"]
			}, {
				apiGroups: [
					"coordination.k8s.io",
				]
				resources: [
					"leases",
				]
				verbs: ["*"]
			}, {
				apiGroups: [
					"apps",
				]
				resources: [
					"daemonsets/finalizers",
					"deployments/finalizers",
					"statefulsets/finalizers",
				]
				verbs: ["update"]
			}, {
				apiGroups: [
					"apps.openshift.io",
				]
				resources: [
					"deploymentconfigs/finalizers",
				]
				verbs: ["update"]
			}]
		}
		"stash-cleaner": {
			// Source: stash/charts/stash-community/templates/cleaner/cluster_role.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name: "stash-cleaner"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
				annotations: {
					"helm.sh/hook":               "pre-delete"
					"helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
				}
			}
			rules: [{
				apiGroups: [
					"admissionregistration.k8s.io",
				]
				resources: [
					"mutatingwebhookconfigurations",
					"validatingwebhookconfigurations",
				]
				verbs: ["delete"]
			}, {
				apiGroups: [
					"apiregistration.k8s.io",
				]
				resources: [
					"apiservices",
				]
				verbs: ["delete"]
			}, {
				apiGroups: [
					"stash.appscode.com",
				]
				resources: [
					"*",
				]
				verbs: ["delete"]
			}, {
				apiGroups: [
					"batch",
				]
				resources: [
					"jobs",
				]
				verbs: ["delete"]
			}]
		}
		"stash-crd-installer": {
			// Source: stash/charts/stash-community/templates/crd-installer/cluster_role.yaml
			apiVersion: "rbac.authorization.k8s.io/v1"
			kind:       "ClusterRole"
			metadata: {
				name: "stash-crd-installer"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade,pre-rollback"
					"helm.sh/hook-delete-policy": "before-hook-creation,hook-failed"
				}
			}
			rules: [{
				apiGroups: [
					"apiextensions.k8s.io",
				]
				resources: [
					"customresourcedefinitions",
				]
				verbs: ["*"]
			}, {
				apiGroups: [
					"stash.appscode.com",
				]
				resources: [
					"*",
				]
				verbs: ["*"]
			}]
		}
	}
	deployments: stash: stash: {
		// Source: stash/charts/stash-community/templates/deployment.yaml
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			name:      "stash"
			namespace: "stash"
			labels: {
				"helm.sh/chart":                "stash-community-v0.24.0"
				"app.kubernetes.io/name":       "stash"
				"app.kubernetes.io/instance":   "stash"
				"app.kubernetes.io/version":    "v0.24.0"
				"app.kubernetes.io/managed-by": "Helm"
			}
		}
		spec: {
			replicas: 1
			selector: matchLabels: {
				"app.kubernetes.io/name":     "stash"
				"app.kubernetes.io/instance": "stash"
			}
			template: {
				metadata: {
					labels: {
						"app.kubernetes.io/name":     "stash"
						"app.kubernetes.io/instance": "stash"
					}
					annotations: "checksum/apiregistration.yaml": "a1113635756a3903fce602c6e6e5b31e5eb26fd27d7e131293c72675694a02cf"
				}
				spec: {
					imagePullSecrets: []
					serviceAccountName: "stash"
					containers: [{
						name: "operator"
						securityContext: {}
						image:           "stashed/stash:v0.24.0"
						imagePullPolicy: "IfNotPresent"
						args: [
							"run",
							"--v=3",
							"--docker-registry=stashed",
							"--image=stash",
							"--image-tag=v0.24.0",
							"--secure-port=8443",
							"--audit-log-path=-",
							"--tls-cert-file=/var/serving-cert/tls.crt",
							"--tls-private-key-file=/var/serving-cert/tls.key",
							"--pushgateway-url=http://stash.stash.svc:56789",
							"--enable-mutating-webhook=true",
							"--enable-validating-webhook=true",
							"--bypass-validating-webhook-xray=false",
							"--use-kubeapiserver-fqdn-for-aks=true",
							"--license-file=/var/run/secrets/appscode/license/key.txt",
							"--license-apiservice=v1beta1.admission.stash.appscode.com",
						]
						ports: [{
							containerPort: 8443
						}]
						env: [{
							name: "POD_NAME"
							valueFrom: fieldRef: fieldPath: "metadata.name"
						}, {
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						}]
						volumeMounts: [{
							mountPath: "/var/serving-cert"
							name:      "serving-cert"
						}, {
							mountPath: "/var/run/secrets/appscode/license"
							name:      "license"
						}]
					}, {
						name: "pushgateway"
						securityContext: {}
						image:           "prom/pushgateway:v1.4.2"
						imagePullPolicy: "IfNotPresent"
						args: [
							"--web.listen-address=:56789",
							"--persistence.file=/var/pv/pushgateway.dat",
						]
						resources: {}
						ports: [{
							containerPort: 56789
						}]
						volumeMounts: [{
							mountPath: "/var/pv"
							name:      "data-volume"
						}, {
							mountPath: "/tmp"
							name:      "stash-scratchdir"
						}]
					}]
					volumes: [{
						emptyDir: {}
						name: "data-volume"
					}, {
						emptyDir: {}
						name: "stash-scratchdir"
					}, {
						name: "serving-cert"
						secret: {
							defaultMode: 420
							secretName:  "stash-apiserver-cert"
						}
					}, {
						name: "license"
						secret: {
							defaultMode: 420
							secretName:  "stash-license"
						}
					}]
					securityContext: fsGroup:         65535
					nodeSelector: "kubernetes.io/os": "linux"
				}
			}
		}
	}
	jobs: stash: "stash-crd-installer": {
		// Source: stash/charts/stash-community/templates/crd-installer/job.yaml
		apiVersion: "batch/v1"
		kind:       "Job"
		metadata: {
			name:      "stash-crd-installer"
			namespace: "stash"
			labels: {
				"helm.sh/chart":                "stash-community-v0.24.0"
				"app.kubernetes.io/name":       "stash"
				"app.kubernetes.io/instance":   "stash"
				"app.kubernetes.io/version":    "v0.24.0"
				"app.kubernetes.io/managed-by": "Helm"
			}
			annotations: {
				"helm.sh/hook":               "pre-install,pre-upgrade,pre-rollback"
				"helm.sh/hook-delete-policy": "before-hook-creation,hook-failed"
			}
		}
		spec: {
			backoffLimit:            3
			activeDeadlineSeconds:   300
			ttlSecondsAfterFinished: 10
			template: spec: {
				serviceAccountName: "stash-crd-installer"
				containers: [{
					name:  "installer"
					image: "stashed/stash-crd-installer:v0.23.0"
					args: [
						"--enterprise=false",
					]
					imagePullPolicy: "IfNotPresent"
				}]
				restartPolicy: "Never"
			}
		}
	}
	mutatingwebhookconfigurations: "": "admission.stash.appscode.com": {
		// Source: stash/charts/stash-community/templates/mutating-webhook.yaml
		// GKE returns Major:"1", Minor:"10+"
		apiVersion: "admissionregistration.k8s.io/v1"
		kind:       "MutatingWebhookConfiguration"
		metadata: {
			name: "admission.stash.appscode.com"
			labels: {
				"helm.sh/chart":                "stash-community-v0.24.0"
				"app.kubernetes.io/name":       "stash"
				"app.kubernetes.io/instance":   "stash"
				"app.kubernetes.io/version":    "v0.24.0"
				"app.kubernetes.io/managed-by": "Helm"
			}
			annotations: {
				"helm.sh/hook":               "pre-install,pre-upgrade"
				"helm.sh/hook-delete-policy": "before-hook-creation"
			}
		}
		webhooks: [{
			name: "deployment.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1alpha1/deploymentmutators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"apps",
					"extensions",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"deployments",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Ignore"
			sideEffects:   "None"
		}, {
			name: "daemonset.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1alpha1/daemonsetmutators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"apps",
					"extensions",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"daemonsets",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Ignore"
			sideEffects:   "None"
		}, {
			name: "statefulset.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1alpha1/statefulsetmutators"
			}
			rules: [{
				operations: [
					"CREATE",
				]
				apiGroups: [
					"apps",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"statefulsets",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Ignore"
			sideEffects:   "None"
		}, {
			name: "deploymentconfig.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1alpha1/deploymentconfigmutators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"apps.openshift.io",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"deploymentconfigs",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Ignore"
			sideEffects:   "None"
		}, {
			name: "restoresession.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1beta1/restoresessionmutators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"stash.appscode.com",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"restoresessions",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Fail"
			sideEffects:   "None"
		}]
	}
	rolebindings: "kube-system": "stash-apiserver-extension-server-authentication-reader": {
		// Source: stash/charts/stash-community/templates/apiregistration.yaml
		// to read the config for terminating authentication
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
		metadata: {
			name:      "stash-apiserver-extension-server-authentication-reader"
			namespace: "kube-system"
			labels: {
				"helm.sh/chart":                "stash-community-v0.24.0"
				"app.kubernetes.io/name":       "stash"
				"app.kubernetes.io/instance":   "stash"
				"app.kubernetes.io/version":    "v0.24.0"
				"app.kubernetes.io/managed-by": "Helm"
			}
		}
		roleRef: {
			kind:     "Role"
			apiGroup: "rbac.authorization.k8s.io"
			name:     "extension-apiserver-authentication-reader"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "stash"
			namespace: "stash"
		}]
	}
	secrets: stash: {
		"stash-apiserver-cert": {
			// Source: stash/charts/stash-community/templates/apiregistration.yaml
			apiVersion: "v1"
			kind:       "Secret"
			metadata: {
				name:      "stash-apiserver-cert"
				namespace: "stash"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
			type: "Opaque"
			data: {
				"tls.crt": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURNakNDQWhxZ0F3SUJBZ0lRS1o0azFWaG1lVXEwcGFKdVprb0lPakFOQmdrcWhraUc5dzBCQVFzRkFEQU4KTVFzd0NRWURWUVFERXdKallUQWVGdzB5TWpFeU16QXdNakUwTWpCYUZ3MHpNakV5TWpjd01qRTBNakJhTUJBeApEakFNQmdOVkJBTVRCWE4wWVhOb01JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBCnl3UzdQd01IbUZXVTN0UHprTmJ5aHBiaDhjWVNrcWllcFk3YTlZRmF6TjRBODhKaXJPK2s5VWVzVFQxc0VyaUYKeHR3a0NmMjRJbEd5N0I0OWVEU0FNa2pqUG9oRkYxSWhhVi9LZHJKQmNIRStkdjI3blVWRmpXbEdKODBIKzdvOQpWa3dhdkxaaC9qUUQ5cTN1SU00VnpGNjJwU1ZNa0NtSjZ5S3dhTFFLT1dwdVZMM21meVFQdnNSOCt3RmdZbzJECkRtV2ZUc1R6T2FCd1g5bTd6ZkxmL1RSaW5ZVlV4M2JLaXF1a1FPSGE5eUp0MlNoSXQ4TFFEbEtrOG5jNE1xZTQKYU5lL28wdGNzV2dDNmlvTnRFaXFoMCs4NHhSY3RpbjNVaDB3SnNURU9vcEtKa3lUZG9HcFU4a2hDOWh2UFJWUwpnVlJWYVZHZ2k1b1FNWENCN3dvdFR3SURBUUFCbzRHS01JR0hNQTRHQTFVZER3RUIvd1FFQXdJRm9EQWRCZ05WCkhTVUVGakFVQmdnckJnRUZCUWNEQVFZSUt3WUJCUVVIQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUUKR0RBV2dCU01WQjIyZUc2UHNid0FEb2xOOFBuaW5KUnZnREFuQmdOVkhSRUVJREFlZ2d0emRHRnphQzV6ZEdGegphSUlQYzNSaGMyZ3VjM1JoYzJndWMzWmpNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUJCSS9PVVp5bnNVM3BpCmtwTnplemNwWDhKSnJXV0Z6WDN1YWVRY0lIeDNBRlp4MCthM1IzanlGbVYwTzlFenB4TzE2bG83NGNzZmEzZTIKUC92VmxQUnhlMFN5dkxpQjFnVmd3VXRrd0dWMmJ3ek1wVkFxNFpSNVNwL0xLcWJvU1ZvTWtzdVZSQzNmaUN1RgpncERGNWhJbFQ2d0xtNHF5TFdLSmRSQlBhbXNGdnZOUlA3RVpMak5tR2JPaytQSjBBc1hvMDNxSlpwOXNKeVh6Ck92UkV5VU04VTZTNEN1V2JHWmx1TC9mdzJjVzRxMUlJTW9WVjVnZFpva0F6WFRmTFB4QnBPOFFtS0RkcHlSMlgKemRPczhGRXA4dFM3UmdEQ0ZaV2toaDFBNEFjUDJOS2JxS1dvcWw3QjdBdGRDRHZDRVBEVWgvVnI4UEFtcWRrNgpSWTRmTmsvZAotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
				"tls.key": "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBeXdTN1B3TUhtRldVM3RQemtOYnlocGJoOGNZU2txaWVwWTdhOVlGYXpONEE4OEppCnJPK2s5VWVzVFQxc0VyaUZ4dHdrQ2YyNElsR3k3QjQ5ZURTQU1rampQb2hGRjFJaGFWL0tkckpCY0hFK2R2MjcKblVWRmpXbEdKODBIKzdvOVZrd2F2TFpoL2pRRDlxM3VJTTRWekY2MnBTVk1rQ21KNnlLd2FMUUtPV3B1VkwzbQpmeVFQdnNSOCt3RmdZbzJERG1XZlRzVHpPYUJ3WDltN3pmTGYvVFJpbllWVXgzYktpcXVrUU9IYTl5SnQyU2hJCnQ4TFFEbEtrOG5jNE1xZTRhTmUvbzB0Y3NXZ0M2aW9OdEVpcWgwKzg0eFJjdGluM1VoMHdKc1RFT29wS0preVQKZG9HcFU4a2hDOWh2UFJWU2dWUlZhVkdnaTVvUU1YQ0I3d290VHdJREFRQUJBb0lCQUdhM1FCMkRaT1pYOW5nKworRzZCc2pjU1E4TFZtalFGaUM3dmRpemNnNW8vZ0cvVUc2U3ZvdUJPb1FoN1dTQ25wMWVUcmRBNFJGOW93b1BnClVPMXVjcVgrWnFzT3V4WXZnYVFVeVJVQTMwY0twTFlEYmxjRjQwakd5SzMrZUZtT1F0WlVydnBudEhDdTFJcU0KT1h6emgrZmN5OEFHZlJRN1VBSmRqSytNMTlkdjhMTkJzVkYyUVdhR01XYlR2Q2ROWjdwMGhSTFNHTld1OWJZMAoxYjVCSjREQzhZYm1ORU1UMVpZZzZkcmRuUXpQS3FGWUx2Vm8wK2JCQkpSVE85dUxoRU52Q2lLeGd0UUN4ZytlCmRTdEdPZWkrMTdicTcyVW9UYnFqaHRaQUc5ekdLMFVTcE1OeEFQY0NtcGdZU0pGNFBsSzdXQ2h6VkpyeHFGZ0YKZEtQOVRnRUNnWUVBMWJyNVp0VWttUnBYNmFJVTVQMVRkemwwZkdYLzhaVUNEbGJVNlVpY0pnNDVpZlBNbDZSQgpQYmcrWjhWenlXS2R2VEc5ZjZlVVVlOXM3QTNXTzZyRHM4ZVhUSzdJbzRkcTdPeW9QM0RKSDJJdVlGdGVNSTZZCjdzUnJONkpjUWlQbjJENjNhZFV6K0dvY0tyYng0TXo4NEo1UEJUQ3krTGNPZjVnMnZ4L2pDczhDZ1lFQTh5dHIKN0dSb1dWZ2gxelFpVFhNa2gxVHVxMTVRaFVBUktZYmNUaEsyTDVDOUdEeFdqZmhiNnBqSDRGaVpRaWVyNWs3cQp6bVRCUEdRQlVpTUhQSjhPcndRMFdMRVE3TmwzT2JQcEFqMnFoZE5rNWRYVzFBZmlLNUVnLzBnOTc1TkduWnZ2CjBienQrN1hBQ1FLWGxicGdmc1hPKy9tM1ZvUEJNcHc4KzZzRlZZRUNnWUFheEtBWDBQb1Vjc2d2NnF6VFFTY0MKOTU4dk5WY28ycEMzV3dpdmJ2aWZpNGlKVG8rQkxvRTlTYVlIT1NPWFJWS2NMMjZjWGxDbE1tZGg2Um03djFkagpYTXdHUHAzQ1hXTjI2T3pwaFNhclY1Q1hZTm9iR3NEc3BvMEhHcjZUU2d2dmVXdGZSZVNNYUQyKzI4clBiTnovCkJOVEF3YWlvbmNTakZsMUU4cWxzNFFLQmdFcVZSZHZTakNMaklqWUVlb1R3elFKcExXOElWWUFaUDJwU1A5MysKWlR5L2t4QU02YXRQd3JsNHRNMTl2endJT1BSQnZra2hwQmNtd1RUMUkzSVhnd1J4TUxFSFZoNmZNSzlWSENHZwowbDJMa2dYZ2lheXM0bFRraFk5bkZBQVlWdTllZGJjSjBLQ0VoV3IrRFlwU0NPaTVPUndWNG9LNWxKYzJUb29PClVXdUJBb0dBQWl2RDZuZVgxVFh6b3ZUSmE3ZGIvR3JtblVtczdPQWVaa2RuYVZLajhObEhvMkdjN1p2bk5xb2IKd0ZVRzM1bGRQTzRnUktmc2JMR3NZd1M1UStXRmR1MW1CTHZWQndTMlBKTEZrOHhtZ3Q5cGNkQk5Dc2FiWWZuNwp6WmN4eGw3UWNMcTJjaFd2RnUzQkZYMmlwaSt6V20wUDdNU3hncGM2ZTlBb0t5NUQvVjg9Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg=="
			}
		}
		"stash-license": {
			// Source: stash/charts/stash-community/templates/license.yaml
			// if license file is provided, then create a secret for license
			apiVersion: "v1"
			kind:       "Secret"
			metadata: {
				name:      "stash-license"
				namespace: "stash"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
			type: "Opaque"
			data: {}
		}
	}
	serviceaccounts: stash: {
		stash: {
			// Source: stash/charts/stash-community/templates/serviceaccount.yaml
			apiVersion: "v1"
			kind:       "ServiceAccount"
			metadata: {
				name:      "stash"
				namespace: "stash"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
			}
		}
		"stash-cleaner": {
			// Source: stash/charts/stash-community/templates/cleaner/serviceaccount.yaml
			apiVersion: "v1"
			kind:       "ServiceAccount"
			metadata: {
				name:      "stash-cleaner"
				namespace: "stash"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
				annotations: {
					"helm.sh/hook":               "pre-delete"
					"helm.sh/hook-delete-policy": "hook-succeeded,hook-failed"
				}
			}
		}
		"stash-crd-installer": {
			// Source: stash/charts/stash-community/templates/crd-installer/serviceaccount.yaml
			apiVersion: "v1"
			kind:       "ServiceAccount"
			metadata: {
				name:      "stash-crd-installer"
				namespace: "stash"
				labels: {
					"helm.sh/chart":                "stash-community-v0.24.0"
					"app.kubernetes.io/name":       "stash"
					"app.kubernetes.io/instance":   "stash"
					"app.kubernetes.io/version":    "v0.24.0"
					"app.kubernetes.io/managed-by": "Helm"
				}
				annotations: {
					"helm.sh/hook":               "pre-install,pre-upgrade,pre-rollback"
					"helm.sh/hook-delete-policy": "before-hook-creation,hook-failed"
				}
			}
		}
	}
	servicemonitors: stash: stash: {
		// Source: stash/charts/stash-community/templates/servicemonitor.yaml
		apiVersion: "monitoring.coreos.com/v1"
		kind:       "ServiceMonitor"
		metadata: {
			name:      "stash"
			namespace: "stash"
			labels: {
				"app.kubernetes.io/name":     "stash"
				"app.kubernetes.io/instance": "stash"
			}
		}
		spec: {
			namespaceSelector: matchNames: [
				"stash",
			]
			selector: matchLabels: {
				"app.kubernetes.io/name":     "stash"
				"app.kubernetes.io/instance": "stash"
			}
			endpoints: [{
				port:        "pushgateway"
				honorLabels: true
			}, {
				port:            "api"
				bearerTokenFile: "/var/run/secrets/kubernetes.io/serviceaccount/token"
				scheme:          "https"
				tlsConfig: {
					ca: secret: {
						name: "stash-apiserver-cert"
						key:  "tls.crt"
					}
					serverName: "stash.stash.svc"
				}
			}]
		}
	}
	services: stash: stash: {
		// Source: stash/charts/stash-community/templates/service.yaml
		apiVersion: "v1"
		kind:       "Service"
		metadata: {
			name:      "stash"
			namespace: "stash"
			labels: {
				"helm.sh/chart":                "stash-community-v0.24.0"
				"app.kubernetes.io/name":       "stash"
				"app.kubernetes.io/instance":   "stash"
				"app.kubernetes.io/version":    "v0.24.0"
				"app.kubernetes.io/managed-by": "Helm"
			}
		}
		spec: {
			ports: [{
				// Port used to expose admission webhook apiserver
				name:       "api"
				port:       443
				targetPort: 8443
			}, {
				// Port used to expose Prometheus pushgateway
				name:       "pushgateway"
				port:       56789
				protocol:   "TCP"
				targetPort: 56789
			}]
			selector: {
				"app.kubernetes.io/name":     "stash"
				"app.kubernetes.io/instance": "stash"
			}
		}
	}
	validatingwebhookconfigurations: "": "admission.stash.appscode.com": {
		// Source: stash/charts/stash-community/templates/validating-webhook.yaml
		// GKE returns Major:"1", Minor:"10+"
		apiVersion: "admissionregistration.k8s.io/v1"
		kind:       "ValidatingWebhookConfiguration"
		metadata: {
			name: "admission.stash.appscode.com"
			labels: {
				"helm.sh/chart":                "stash-community-v0.24.0"
				"app.kubernetes.io/name":       "stash"
				"app.kubernetes.io/instance":   "stash"
				"app.kubernetes.io/version":    "v0.24.0"
				"app.kubernetes.io/managed-by": "Helm"
			}
			annotations: {
				"helm.sh/hook":               "pre-install,pre-upgrade"
				"helm.sh/hook-delete-policy": "before-hook-creation"
			}
		}
		webhooks: [{
			name: "restic.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1alpha1/resticvalidators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"stash.appscode.com",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"restics",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Fail"
			sideEffects:   "None"
		}, {
			name: "recovery.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1alpha1/recoveryvalidators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"stash.appscode.com",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"recoveries",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Fail"
			sideEffects:   "None"
		}, {
			name: "repository.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1alpha1/repositoryvalidators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"stash.appscode.com",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"repositories",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Fail"
			sideEffects:   "None"
		}, {
			name: "restoresession.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1beta1/restoresessionvalidators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"stash.appscode.com",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"restoresessions",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Fail"
			sideEffects:   "None"
		}, {
			name: "backupconfiguration.admission.stash.appscode.com"
			clientConfig: service: {
				namespace: "default"
				name:      "kubernetes"
				path:      "/apis/admission.stash.appscode.com/v1beta1/backupconfigurationvalidators"
			}
			rules: [{
				operations: [
					"CREATE",
					"UPDATE",
				]
				apiGroups: [
					"stash.appscode.com",
				]
				apiVersions: [
					"*",
				]
				resources: [
					"backupconfigurations",
				]
			}]
			admissionReviewVersions: ["v1beta1"]
			failurePolicy: "Fail"
			sideEffects:   "None"
		}]
	}
}
