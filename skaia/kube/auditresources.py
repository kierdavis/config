#!/usr/bin/env nix-shell
#!nix-shell -p python3 -i python3

import json
import subprocess

kubectl_result = subprocess.run(["kubectl", "get", "pod", "-o", "json", "-A"], check=True, stdout=subprocess.PIPE)
pods = json.loads(kubectl_result.stdout)["items"]
for pod in pods:
  # Skip csi pods since rook operator overwrites any changes I make to the resource attributes.
  if pod["metadata"]["name"].startswith(("kube-apiserver-", "kube-controller-manager-", "kube-scheduler-", "csi-")):
    continue
  if "priorityClassName" not in pod["spec"]:
    raise SystemExit(f"pod {pod['metadata']['name']} in namespace {pod['metadata']['namespace']} is missing priorityClassName")
  for container in pod["spec"]["containers"]:
    for (quota_type, resource) in (("requests", "cpu"), ("requests", "memory"), ("limits", "memory")):
      if resource not in container.get("resources", {}).get(quota_type, {}):
        raise SystemExit(f"container {container['name']} in pod {pod['metadata']['name']} in namespace {pod['metadata']['namespace']} is missing resources.{quota_type}.{resource}")
