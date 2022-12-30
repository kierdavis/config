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
				caBundle:             "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lSQUltRnFzYTJEczR0RU0zb2w4cHpEd293RFFZSktvWklodmNOQVFFTEJRQXcKRFRFTE1Ba0dBMVVFQXhNQ1kyRXdIaGNOTWpJeE1qTXdNREV4TmpNd1doY05Nekl4TWpJM01ERXhOak13V2pBTgpNUXN3Q1FZRFZRUURFd0pqWVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmJxCldwR21zSHlKeC9EY3RScllUL0R5YUNPeEczTG4xNWxKOExiU0tHMmU5QjVGS0hDYndjemNzQWJtOEhJckluUksKQ2RxZkxKbXBCK1RpNWdrK1N4ZnFSRStoMWpMRmJDZmhkc0k4ZjBYQTdEZGtpcm1iam5iY0xQTmk3RFZoVFFqQwp1QlRGaEhyYlJPVXViMHhYdFV0WEUvRHlHcEZDcUxSWnVKQ1JWL3ZZSkY3NDlqcDVvVHBnTysxeG1HOXRKd3M2Ci9Lb3d2OEZrM0FWTTRoaGNhWko3K0NkZzFKUHhLcnRGU2M5dlQvaDZKamlnaFV4ZWRETk1IWjM1K2MxRExNOWYKdWs4QldrTjhrSC9ab0FoTTVtdW1VdGR2cVMrbW1nc2p5dEFSRUw0b0VJMjhQeENtRWQwMHpsQktlODd0TXlOawpsRGFRZEFZcHZvQlRyNWg2dThNQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJSdzVuUEdDcVVwYUVHYzNjemZqck1QOXlBWk5EQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFrZEc1dk1SawpjZGROM2JteE9nUUQzUndPTGdTdERkd3JhdE8xWUV1bkVaM1pOekRuVEhnSGxySDZvYUdGamhGRmo5UGplY01DCktmaTBFaEFkNyt6N01uNldRd2VDSDRLWFZyUVEySWU2T3VvQ2lsOUJEVmxrSS9UNjRrZWd4cEo4SnZzMzVwSWoKdFN3NEIxUjNTNjFTUG9KMlF0QWJpUTJqK3Vkc2hKM2VtRWlVK3lOck4veUVYQlA5M2YwYWY2UENoMHNzZEhHbApDcjNFMWNnaDNlSzN2SmhiTnJaT254SlppT0xNbVpkOC9wVis5aHI2R3dGc1l4TmZIMUhCeXF0Y2ZlbTB0ck5pCmZCcFVvUVlMOVB2cFNPZzdpdDZzZTBkQjFLazRxR0ZvYUVmaTgrdndQK3BONmxiWWdaYlMrOUxZd2tFdlcvN2UKN3QxblpPUG0xeTEwRFE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
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
				caBundle:             "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lSQUltRnFzYTJEczR0RU0zb2w4cHpEd293RFFZSktvWklodmNOQVFFTEJRQXcKRFRFTE1Ba0dBMVVFQXhNQ1kyRXdIaGNOTWpJeE1qTXdNREV4TmpNd1doY05Nekl4TWpJM01ERXhOak13V2pBTgpNUXN3Q1FZRFZRUURFd0pqWVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmJxCldwR21zSHlKeC9EY3RScllUL0R5YUNPeEczTG4xNWxKOExiU0tHMmU5QjVGS0hDYndjemNzQWJtOEhJckluUksKQ2RxZkxKbXBCK1RpNWdrK1N4ZnFSRStoMWpMRmJDZmhkc0k4ZjBYQTdEZGtpcm1iam5iY0xQTmk3RFZoVFFqQwp1QlRGaEhyYlJPVXViMHhYdFV0WEUvRHlHcEZDcUxSWnVKQ1JWL3ZZSkY3NDlqcDVvVHBnTysxeG1HOXRKd3M2Ci9Lb3d2OEZrM0FWTTRoaGNhWko3K0NkZzFKUHhLcnRGU2M5dlQvaDZKamlnaFV4ZWRETk1IWjM1K2MxRExNOWYKdWs4QldrTjhrSC9ab0FoTTVtdW1VdGR2cVMrbW1nc2p5dEFSRUw0b0VJMjhQeENtRWQwMHpsQktlODd0TXlOawpsRGFRZEFZcHZvQlRyNWg2dThNQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJSdzVuUEdDcVVwYUVHYzNjemZqck1QOXlBWk5EQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFrZEc1dk1SawpjZGROM2JteE9nUUQzUndPTGdTdERkd3JhdE8xWUV1bkVaM1pOekRuVEhnSGxySDZvYUdGamhGRmo5UGplY01DCktmaTBFaEFkNyt6N01uNldRd2VDSDRLWFZyUVEySWU2T3VvQ2lsOUJEVmxrSS9UNjRrZWd4cEo4SnZzMzVwSWoKdFN3NEIxUjNTNjFTUG9KMlF0QWJpUTJqK3Vkc2hKM2VtRWlVK3lOck4veUVYQlA5M2YwYWY2UENoMHNzZEhHbApDcjNFMWNnaDNlSzN2SmhiTnJaT254SlppT0xNbVpkOC9wVis5aHI2R3dGc1l4TmZIMUhCeXF0Y2ZlbTB0ck5pCmZCcFVvUVlMOVB2cFNPZzdpdDZzZTBkQjFLazRxR0ZvYUVmaTgrdndQK3BONmxiWWdaYlMrOUxZd2tFdlcvN2UKN3QxblpPUG0xeTEwRFE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
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
				caBundle:             "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lSQUltRnFzYTJEczR0RU0zb2w4cHpEd293RFFZSktvWklodmNOQVFFTEJRQXcKRFRFTE1Ba0dBMVVFQXhNQ1kyRXdIaGNOTWpJeE1qTXdNREV4TmpNd1doY05Nekl4TWpJM01ERXhOak13V2pBTgpNUXN3Q1FZRFZRUURFd0pqWVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTmJxCldwR21zSHlKeC9EY3RScllUL0R5YUNPeEczTG4xNWxKOExiU0tHMmU5QjVGS0hDYndjemNzQWJtOEhJckluUksKQ2RxZkxKbXBCK1RpNWdrK1N4ZnFSRStoMWpMRmJDZmhkc0k4ZjBYQTdEZGtpcm1iam5iY0xQTmk3RFZoVFFqQwp1QlRGaEhyYlJPVXViMHhYdFV0WEUvRHlHcEZDcUxSWnVKQ1JWL3ZZSkY3NDlqcDVvVHBnTysxeG1HOXRKd3M2Ci9Lb3d2OEZrM0FWTTRoaGNhWko3K0NkZzFKUHhLcnRGU2M5dlQvaDZKamlnaFV4ZWRETk1IWjM1K2MxRExNOWYKdWs4QldrTjhrSC9ab0FoTTVtdW1VdGR2cVMrbW1nc2p5dEFSRUw0b0VJMjhQeENtRWQwMHpsQktlODd0TXlOawpsRGFRZEFZcHZvQlRyNWg2dThNQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJSdzVuUEdDcVVwYUVHYzNjemZqck1QOXlBWk5EQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFrZEc1dk1SawpjZGROM2JteE9nUUQzUndPTGdTdERkd3JhdE8xWUV1bkVaM1pOekRuVEhnSGxySDZvYUdGamhGRmo5UGplY01DCktmaTBFaEFkNyt6N01uNldRd2VDSDRLWFZyUVEySWU2T3VvQ2lsOUJEVmxrSS9UNjRrZWd4cEo4SnZzMzVwSWoKdFN3NEIxUjNTNjFTUG9KMlF0QWJpUTJqK3Vkc2hKM2VtRWlVK3lOck4veUVYQlA5M2YwYWY2UENoMHNzZEhHbApDcjNFMWNnaDNlSzN2SmhiTnJaT254SlppT0xNbVpkOC9wVis5aHI2R3dGc1l4TmZIMUhCeXF0Y2ZlbTB0ck5pCmZCcFVvUVlMOVB2cFNPZzdpdDZzZTBkQjFLazRxR0ZvYUVmaTgrdndQK3BONmxiWWdaYlMrOUxZd2tFdlcvN2UKN3QxblpPUG0xeTEwRFE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
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
					annotations: "checksum/apiregistration.yaml": "ac939aa32965e09a07f4cc831757c620af72f155f3dd070b0710c4465fc1ea82"
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
						resources: requests: cpu: "100m"
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1alpha1/deploymentmutators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1alpha1/daemonsetmutators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1alpha1/statefulsetmutators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1alpha1/deploymentconfigmutators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1beta1/restoresessionmutators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
				"tls.crt": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURNakNDQWhxZ0F3SUJBZ0lRZENkNUJocGNFdXpBWE9NS253UUV1VEFOQmdrcWhraUc5dzBCQVFzRkFEQU4KTVFzd0NRWURWUVFERXdKallUQWVGdzB5TWpFeU16QXdNVEUyTXpGYUZ3MHpNakV5TWpjd01URTJNekZhTUJBeApEakFNQmdOVkJBTVRCWE4wWVhOb01JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBCis3SmxzYi9mWkJLU0xqNEFDODI1RFp3Z1dIRC9uQjhwZzFtNUVhODlrYzRWak83c3R4ME1mWEdob3ZTOW1PTXIKQTA0Qys4UjN5bHhpczd6M1FaWnlLRkhsTWdwYVZjSTdidXVxaEdjeFphdTQ1aEhUZmF2R29tZmhBdk1kMVIwRwowZ2ZOa0htL0pYNllhSXA2YXkvdzlnSGdmY3JScUFYNDNBdCtyUnIrZ25VYjd4VHE3NW9vdU90ODk0WWMvNDArCkxYTFpraDE4ckFpaTNBMG9EeFdPUGN3dFIraGorMEFCeVN0c0tHN2xZejBkbkl0WXJvSWZWN0ZHNThKR1dFalcKRTBvbWlsWlVaK3B6Z0s4aFhDWU5XNjlDK3lVbXhZRlQvTUJjT2VzQVJDVG1wMFVQbWIyVHJmMmo0SnEvWE9UVApkeEFBZU1GMlRuTDJRTEN2c0xUdzJ3SURBUUFCbzRHS01JR0hNQTRHQTFVZER3RUIvd1FFQXdJRm9EQWRCZ05WCkhTVUVGakFVQmdnckJnRUZCUWNEQVFZSUt3WUJCUVVIQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUUKR0RBV2dCUnc1blBHQ3FVcGFFR2MzY3pmanJNUDl5QVpOREFuQmdOVkhSRUVJREFlZ2d0emRHRnphQzV6ZEdGegphSUlQYzNSaGMyZ3VjM1JoYzJndWMzWmpNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUFLZXRTV084SXJxSVpaCkxZL2lCRStkSEMwdXl3MVhFM3BaVURJaWpxVHZ3U3VsYkNyWjZQM0hXMWlvV1drK0pDTEl5azlTY0EvUEdrNEQKV3NTbDlUNmhNWGtYME5pZDB5SVZCR1NiMUFWN0E4bnNmbUdPUkJuQjJsOWRsTHlKaWxmSjVLYXFYcy9HYTVybgo4bjJOSENxQjlXYmpUMHRTYnU1UkR4cjdwTm55Z09ZbnFlcC9PYzBHYmlEc1FHNCttanJWN3oyKzhWN1hpclVCCklBa01rc1VCcCt0Wm51MnhFMWhHdHdxanltM0NuMzVJY2ZUa29raHV5dTE2NU85clBFbHVMWkFuK0QvRVlQVDAKK0NJSTRZV3N1b1JhSHhBc3RhQU52ci9CVndYMW1Ib1E0Um1UbkJlOXQ0THdoU1BKZFpoNndGWk4rZ25KaFp3SApxdWFLMkFIUQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
				"tls.key": "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBKzdKbHNiL2ZaQktTTGo0QUM4MjVEWndnV0hEL25COHBnMW01RWE4OWtjNFZqTzdzCnR4ME1mWEdob3ZTOW1PTXJBMDRDKzhSM3lseGlzN3ozUVpaeUtGSGxNZ3BhVmNJN2J1dXFoR2N4WmF1NDVoSFQKZmF2R29tZmhBdk1kMVIwRzBnZk5rSG0vSlg2WWFJcDZheS93OWdIZ2ZjclJxQVg0M0F0K3JScitnblViN3hUcQo3NW9vdU90ODk0WWMvNDArTFhMWmtoMThyQWlpM0Ewb0R4V09QY3d0UitoaiswQUJ5U3RzS0c3bFl6MGRuSXRZCnJvSWZWN0ZHNThKR1dFaldFMG9taWxaVVorcHpnSzhoWENZTlc2OUMreVVteFlGVC9NQmNPZXNBUkNUbXAwVVAKbWIyVHJmMmo0SnEvWE9UVGR4QUFlTUYyVG5MMlFMQ3ZzTFR3MndJREFRQUJBb0lCQUVFbG5NTFVPZnNKLzRJdQpsQTU2RWhMZXZWU0c4dkl5OHFqSDJXb2xaSmRQc3k1R1RVamNJUFo3S2U0bTBNZzR6RkpQcCtBSXEwVGFnc1dvCi9JcWlhU3ZjZnFsa0dwdWw2WUk5UjJaNzIwSkluMVFWZXh0RkVlWEpZMmxEQ2c2Mk02UzdWazYxNUc3TkJKL1MKYi9zOGJtOE9iMCsvNW1KS0lXNjdIdStwVkFUcHpZaDh5bkw0b1I3RjQwdmxacm1iZ0MzUHVOTDJFbFQ1c3VQcgp6WEI3ZXlFZ2Zobi9kV080RXE0L2w0VC94eVYxQi9oUUl1Ry9xbGtsZVJqeDhpMXl1L0s0T3VQUDlNcEhKSERsClQrZnBqTGZUSDRKd3h3alMwVlEzL3VDaXpOSmgrSzBFdWszdGVwbWx2QUVSaEI2ZXFqVFdaSHgvZ09zZjZScm8KUVI1ekN4a0NnWUVBL2MzL0krbUx0K0xjbmFkNlB4UTlGd2FWaGUrVlpvWlhMblNKQkFiYnVKTWxML3QvdXF3QgprTmcvaTFjc1FDZWRBZ3ZiUmtzMC9nV2MzaGF3VUtZRXNZY3YrSTdsUDF4SGhGVlNJbXR4NmpMaHhxUkkvb1lvClRqZHd2SHZJbjE3MHgzQ1RwSVNmQ01Mby81NXZqYmtYZ2NzR012c2NQeEdDWmhaWCtsRnl6MmNDZ1lFQS9kKzcKdGhncVRIR3U2eDRjMGc2WUVXWm02R25SbEJvREF4b1NBeGtLQzVDY0d0c0wvaDgrMDlqWW1EUFZxcEppZnoyUApycUk1ck8rK3Z0VTRQdGI0Yjl6cVhDbDlIY1BROC9mTWV5UXNxajFCR1JLb0NkdmRuWnVFYmFUWWM5emNTV3paCjJCQ012OGhSeUlMNnh1alZwdnBIa1dtYWtlSmNzUVhSdW1yTkRtMENnWUVBZy8wMjdGUXVSdWtCMWpNY2plVlcKaDd6eTBYNXc4YXAzZUQ4K2FndXZCR1B4ZU95UDFtSlJSaVJQbDRVMERBRU4wOXlhb2duR2V6d3NBZ3RHa2dwawpjblpkYWlQVjhJZHE0ZFVGSzhVNHJwVGJlVlJDYWFzWEZ1WWFDTXRPNENLZnBZQlVKOENZZkJQdzI4NW5NUXJLCndNTDJiRmpPcmJYTFhJL09ITzF5aVkwQ2dZRUFxekpPZ05MMjR5bmVUTXEzb0tjYXdORVBJRGNManhXalpsb1UKUDJhSk1aZEl6WXRkSVBhdEJXcTdWSmZQeEFDR3owc1NNeTlPT1dKS2ZLR0lGa2djckVLSy82OHlvZm5FVkdDTAowWlpwVUR1U1JIZ2lQTk81TkdrRStuTXBTNmhxSEZGODdZanJnUUJ5dGdZdFdpajB1bThZQitUd3lPT2VvZmxNCm5xc2FzRmtDZ1lFQTV5M3ozQkd6aHJKQnEydWVKTDQzam44Y3ViaGZVUjBkQ3VkV2tNYnBPV0syZDlxZk5hcnIKNEJ4WFRTM1FQeUhKYTEzYkVpSTBJYTZscWRKaEo3alAzZkJ3TmRKdHNGQkFZd1RremExdFRoblAzQ3NzeUdsLwppdFpNaW5SenZ1bGROampIeFg4QXl3TUhDb01jZDl1dm9WaHRQb29zVGpIeFM5REc3WnR4RDhBPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1alpha1/resticvalidators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1alpha1/recoveryvalidators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1alpha1/repositoryvalidators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1beta1/restoresessionvalidators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
			clientConfig: {
				service: {
					namespace: "default"
					name:      "kubernetes"
					path:      "/apis/admission.stash.appscode.com/v1beta1/backupconfigurationvalidators"
				}
				caBundle: "bm90LWNhLWNlcnQ="
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
