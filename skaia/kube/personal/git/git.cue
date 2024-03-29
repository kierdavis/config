package git

import (
	"cue.skaia/kube/system/stash"
)

labels: app: "git"

resources: configmaps: "personal": "git-authorized-keys": {
	metadata: "labels": labels
	data: "all.pub": """
		ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr5oNVuZMYi1SwOUpIt13uhfSMzpP1e4g7WLjQJPa+vq8zOD2+ryHJgLbN+lw73ZQOVlSc1DZ4aA5DFF9SdPXdIct8hWw5DBqktO2vO7w7i7V68RrsGwcxHfMtbA7kfm1plO8tCcoP3IuWFONysowOhU0CKzwfsvnHex6s+t5GE6Y4KK+aFpzrqRkP2VnkK0nMP+2jeH4AMNEIZg1scO7BCFZZYeBPNLdT3tbnH+z6BPHr1CpT2iEaZEKsjGUPLdoqrXC2fqSFn8PJRCYfRAt3dxV1lQbZ/dt2sUZgzBz9XRhp5WPzWhRv6CVx2DFD3TnLkjQoC/7sHA6NRYJVI5b3 kier@coloris
		ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwUC9OqLttu9B4qk+V83vwCBKKgqjwF41BG5fj5wgQ+ kier@saelli
		ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcD2fIBle9XgHokzJ4Y0NLJXVDZoUxjXANZkK9/aXEgPZrDLW8qMtXBEPPvmxRIqOJO8idnxseBZScCQdnJghPWGnK9IJ6be4s0Dwcxy+ZMTVpyQLUPXCLAbInZhXkD+fkm86p1dLLIvF6fAE1EkKSqImqfOURfTIiFdBseY6mLV1f2Hx5pa3IF1Eh3T7fAQEsmXt+doDdQFZpdwVhBrvPKy0VpHTPB4JkUAwLBu9D84dwrz8pQg9AsQDBIAJhOj81yw2sOO/+wiXY/mLeAiwyhNULbYYIM0ZtT5qzlpHy47gwdNaaFpvbc9C2DGsyymLhQW2v5WUQZMdWKlo61wmDQFagZVYZUflwD0ikZKqMBRcVV7uHuD3e3vTjPR+A/ArFFA9BIRsvHE/0y6e9vTogGSfC/tswiftBhiWrc09dAEyLZwmcJpHEIkd2QrCwYSs9EZw6L+3g9gPN2oeXI8dvhz/IBIjvmFYl0uNvdxRb5FfHeJuCJKI52dLfsgvy9YHb4JarDKWlYZYApHa69x+OEdUJ82OaXAsoRjIP1kPKIsv9WjdUzcDimDdD/nHiIrY0XBrsvAHTyVmz6nXemHoN+4xTByCvmycuo3G1XLd1H0Xofw6OigaQPihoDgB7OVZEKTBrJTlrk7H+v8YJvaeRt21F3suyZNyuVj5SZRVn3Q== PasswordStore@kier-pixel4-201911
		ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILt1KPQo71lhJbQ2YNvfIj8m+qizGSmWOwjBN0ikAKiU kierd@colorisw
		ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDD0JdOx2GHCZo0II/+UPJXO6dj2W+wFBQEy1nLqjOl4 PasswordStore@kier-pixel4a-202108
		"""
}

resources: statefulsets: "personal": "git": {
	metadata: "labels": labels
	spec: {
		selector: matchLabels: labels
		serviceName: "git"
		replicas:    1
		template: {
			metadata: "labels": labels
			spec: {
				priorityClassName: "personal-critical"
				containers: [{
					name:  "main"
					image: "docker.io/jkarlos/git-server-docker"
					ports: [{name: "ssh", containerPort: 22}]
					volumeMounts: [
						{name: "repositories", mountPath: "/git-server/repos"},
						{name: "keys", mountPath:         "/git-server/keys", readOnly: true},
					]
					resources: requests: {
						cpu:    "1m"
						memory: "5Mi"
					}
				}]
				volumes: [{name: "keys", configMap: name: "git-authorized-keys"}]
			}
		}
		volumeClaimTemplates: [{
			metadata: name: "repositories"
			spec: {
				accessModes: ["ReadWriteOnce"]
				storageClassName: "ceph-blk-gp0"
				resources: requests: storage: "1Gi"
			}
		}]
	}
}

resources: services: "personal": "git": {
	metadata: "labels": labels
	spec: {
		selector: labels
		ports: [{name: "ssh", port: 22, targetPort: "ssh"}]
	}
}

resources: backupconfigurations: "personal": "git-repositories": spec: {
	driver: "Restic"
	repository: {
		name:      "personal-git-repositories-b2"
		namespace: "stash"
	}
	retentionPolicy: {
		name:        "personal-git-repositories-b2"
		keepDaily:   7
		keepWeekly:  5
		keepMonthly: 12
		keepYearly:  1000
		prune:       true
	}
	schedule: "0 2 * * 4"
	target: {
		ref: {
			apiVersion: "apps/v1"
			kind:       "StatefulSet"
			name:       "git"
		}
		volumeMounts: [{name: "repositories", mountPath: "/repositories"}]
		paths: ["/repositories"]
		exclude: ["lost+found"]
	}
	timeOut: "6h"
}

resources: (stash.repositoryTemplate & {namespace: "personal", name: "git-repositories"}).resources
