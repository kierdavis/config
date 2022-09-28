# From https://github.com/rook/rook/blob/v1.10.1/deploy/examples/toolbox.yaml

resource "kubernetes_manifest" "deployment_rook_ceph_rook_ceph_tools" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "rook-ceph-tools"
      }
      "name" = "rook-ceph-tools"
      "namespace" = "rook-ceph"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "rook-ceph-tools"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "rook-ceph-tools"
          }
        }
        "spec" = {
          "containers" = [
            {
              "command" = [
                "/bin/bash",
                "-c",
                <<-EOT
                # Replicate the script from toolbox.sh inline so the ceph image
                # can be run directly, instead of requiring the rook toolbox
                CEPH_CONFIG="/etc/ceph/ceph.conf"
                MON_CONFIG="/etc/rook/mon-endpoints"
                KEYRING_FILE="/etc/ceph/keyring"
                
                # create a ceph config file in its default location so ceph/rados tools can be used
                # without specifying any arguments
                write_endpoints() {
                  endpoints=$(cat $${MON_CONFIG})
                
                  # filter out the mon names
                  # external cluster can have numbers or hyphens in mon names, handling them in regex
                  # shellcheck disable=SC2001
                  mon_endpoints=$(echo "$${endpoints}"| sed 's/[a-z0-9_-]\+=//g')
                
                  DATE=$(date)
                  echo "$DATE writing mon endpoints to $${CEPH_CONFIG}: $${endpoints}"
                    cat <<EOF > $${CEPH_CONFIG}
                [global]
                mon_host = $${mon_endpoints}
                
                [client.admin]
                keyring = $${KEYRING_FILE}
                EOF
                }
                
                # watch the endpoints config file and update if the mon endpoints ever change
                watch_endpoints() {
                  # get the timestamp for the target of the soft link
                  real_path=$(realpath $${MON_CONFIG})
                  initial_time=$(stat -c %Z "$${real_path}")
                  while true; do
                    real_path=$(realpath $${MON_CONFIG})
                    latest_time=$(stat -c %Z "$${real_path}")
                
                    if [[ "$${latest_time}" != "$${initial_time}" ]]; then
                      write_endpoints
                      initial_time=$${latest_time}
                    fi
                
                    sleep 10
                  done
                }
                
                # create the keyring file
                cat <<EOF > $${KEYRING_FILE}
                [$${ROOK_CEPH_USERNAME}]
                key = $${ROOK_CEPH_SECRET}
                EOF
                
                # write the initial config file
                write_endpoints
                
                # continuously update the mon endpoints if they fail over
                watch_endpoints
                
                EOT
                ,
              ]
              "env" = [
                {
                  "name" = "ROOK_CEPH_USERNAME"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "ceph-username"
                      "name" = "rook-ceph-mon"
                    }
                  }
                },
                {
                  "name" = "ROOK_CEPH_SECRET"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "ceph-secret"
                      "name" = "rook-ceph-mon"
                    }
                  }
                },
              ]
              "image" = "quay.io/ceph/ceph:v17.2.3"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "rook-ceph-tools"
              "securityContext" = {
                "runAsGroup" = 2016
                "runAsNonRoot" = true
                "runAsUser" = 2016
              }
              "tty" = true
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/ceph"
                  "name" = "ceph-config"
                },
                {
                  "mountPath" = "/etc/rook"
                  "name" = "mon-endpoint-volume"
                },
              ]
            },
          ]
          "dnsPolicy" = "ClusterFirstWithHostNet"
          "tolerations" = [
            {
              "effect" = "NoExecute"
              "key" = "node.kubernetes.io/unreachable"
              "operator" = "Exists"
              "tolerationSeconds" = 5
            },
          ]
          "volumes" = [
            {
              "configMap" = {
                "items" = [
                  {
                    "key" = "data"
                    "path" = "mon-endpoints"
                  },
                ]
                "name" = "rook-ceph-mon-endpoints"
              }
              "name" = "mon-endpoint-volume"
            },
            {
              "emptyDir" = {}
              "name" = "ceph-config"
            },
          ]
        }
      }
    }
  }
}
