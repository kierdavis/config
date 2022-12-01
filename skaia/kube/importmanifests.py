#!/usr/bin/env nix-shell
#!nix-shell -p cue -p "python3.withPackages(py: with py; [ruamel-yaml])" -i python3

import pathlib
import re
import subprocess
import sys
import tarfile
import urllib.request
from ruamel.yaml import YAML

components = {
  "calico": {
    "version": "3.24.3",
    "yaml_url": "https://github.com/projectcalico/calico/raw/v{version}/manifests/calico.yaml",
    "dest_dir": "system/calico",
  },
  "metrics-server": {
    "version": "0.6.1",
    "yaml_url": "https://github.com/kubernetes-sigs/metrics-server/releases/download/v{version}/components.yaml",
    "dest_dir": "system/metricsserver",
  },
  "prometheus": {
    "version": "0.11.0",
    "tar_url": "https://github.com/prometheus-operator/kube-prometheus/archive/refs/tags/v{version}.tar.gz",
    "tar_member_regexp": r"^[^/]*/manifests/",
    "dest_dir": "system/prometheus",
  },
  "rook-ceph": {
    "version": "1.10.6",
    "tar_url": "https://github.com/rook/rook/archive/refs/tags/v{version}.tar.gz",
    "tar_member_regexp": r"^[^/]*/deploy/examples/(common|crds|operator|toolbox)\.yaml$",
    "dest_dir": "system/rookceph",
  },
}

def patch_resource(resource):
  if resource["kind"] == "DaemonSet" and resource["metadata"]["name"] == "calico-node":
    assert resource["spec"]["template"]["spec"]["initContainers"][0]["name"] == "upgrade-ipam"
    del resource["spec"]["template"]["spec"]["initContainers"][0]
    node_container = resource["spec"]["template"]["spec"]["containers"][0]
    assert node_container["name"] == "calico-node"
    set_env(node_container, "CALICO_IPV4POOL_BLOCK_SIZE", "26")
    set_env(node_container, "CALICO_IPV4POOL_IPIP", "Never")
    set_env(node_container, "CALICO_IPV4POOL_VXLAN", "Never")
    set_env(node_container, "CALICO_IPV4POOL_NAT_OUTGOING", "true")
    set_env(node_container, "CALICO_IPV4POOL_NODE_SELECTOR", "all()")
    set_env(node_container, "CALICO_IPV4POOL_DISABLE_BGP_EXPORT", "false")
    setup_dynamic_env(node_container, "CALICO_IPV4POOL_CIDR", desired_index=0)
  if resource["kind"] == "Deployment" and resource["metadata"]["name"] == "metrics-server":
    # x509: cannot validate certificate for 10.88.1.2 because it doesn't contain any IP SANs
    # Unfortunately Talos doesn't seem to have an option to add SANs to the kubelet's certificate.
    assert resource["spec"]["template"]["spec"]["containers"][0]["name"] == "metrics-server"
    resource["spec"]["template"]["spec"]["containers"][0]["args"].append("--kubelet-insecure-tls")
  if resource["kind"] in {"Alertmanager"}:
    return None
  if resource["kind"] == "Prometheus":
    # I want to override these fields.
    del resource["spec"]["alerting"]
    del resource["spec"]["replicas"]
  if resource["kind"] == "DaemonSet" and resource["metadata"]["name"] == "node-exporter":
    del resource["spec"]["template"]["spec"]["priorityClassName"]
  if resource["kind"] == "Service" and resource["metadata"]["name"] == "grafana":
    assert resource["spec"]["ports"][0]["name"] == "http"
    del resource["spec"]["ports"][0]["port"]
  if resource["kind"] == "NetworkPolicy" and resource["metadata"]["name"] == "grafana":
    del resource["spec"]["ingress"][0]["ports"][0]["port"]
  if resource["kind"] == "ConfigMap" and resource["metadata"]["name"] == "rook-ceph-operator-config":
    del resource["data"]["CSI_PROVISIONER_REPLICAS"]
  return resource

def set_env(container, name, value):
  lookup_env(container, name)["value"] = value

def setup_dynamic_env(container, name, *, desired_index):
  env = lookup_env(container, name)
  container["env"].remove(env)
  container["env"].insert(desired_index, env)

def lookup_env(container, name):
  for env in container["env"]:
    if env["name"] == name:
      return env
  env = {"name": name}
  container["env"].append(env)
  return env

def main():
  component = components[sys.argv[1]]
  dest_dir = pathlib.Path(__file__).parent / component["dest_dir"]
  dest_dir.mkdir(parents=True, exist_ok=True)
  dest_yaml_path = dest_dir / "imported.yaml"
  with open(dest_yaml_path, "w") as dest_yaml_fileobj:
    with YAML(output=dest_yaml_fileobj) as yaml:
      resources = {}
      print("fetch...", file=sys.stderr)
      for resource in flatten_resource_lists(fetch_resources(component, yaml)):
        resource = patch_resource(resource)
        if resource is None:
          continue
        kind = kind_to_plural(resource["kind"])
        ns = resource["metadata"].get("namespace", "")  # TODO: change to clusterWide
        name = resource["metadata"]["name"]
        print(f"  discovered resources[{kind!r}][{ns!r}][{name!r}]", file=sys.stderr)
        resources.setdefault(kind, {}).setdefault(ns, {})[name] = resource
      print("sort...", file=sys.stderr)
      sort_dicts(resources, depth=3)
      print("serialize...", file=sys.stderr)
      yaml.dump({"resources": resources})
      del resources, yaml
  cue_package = dest_dir.name
  print("cue import...", file=sys.stderr)
  subprocess.run(["cue", "import", "--package", cue_package, "--force", dest_yaml_path.name], cwd=dest_dir, check=True)
  print("cue fmt...", file=sys.stderr)
  subprocess.run(["cue", "fmt", dest_yaml_path.with_suffix(".cue")], check=True)
  print("housekeeping...", file=sys.stderr)
  gitignore_path = dest_dir / ".gitignore"
  if not gitignore_path.exists():
    gitignore_path.write_text(dest_yaml_path.name + "\n")

def fetch_resources(component, yaml):
  if "tar_url" in component:
    tar_url = component["tar_url"].format(**component)
    with urllib.request.urlopen(tar_url) as tar_fileobj:
      with tarfile.open(fileobj=tar_fileobj, mode="r|gz") as tar:
        for tar_member in tar:
          if tar_member.isreg() and re.match(component["tar_member_regexp"], tar_member.name):
            yield from yaml.load_all(tar.extractfile(tar_member))
  elif "yaml_url" in component:
    yaml_url = component["yaml_url"].format(**component)
    with urllib.request.urlopen(yaml_url) as yaml_fileobj:
      yield from yaml.load_all(yaml_fileobj)
  else:
    raise Exception("component doesn't specify how to fetch its resources")

def flatten_resource_lists(manifests):
  for manifest in manifests:
    if manifest["kind"].endswith("List") and "items" in manifest:
      yield from flatten_resource_lists(manifest["items"])
    else:
      yield manifest

def kind_to_plural(kind):
  kind = kind.lower()
  if kind.endswith("y"):
    return kind[:-1] + "ies"
  if kind.endswith("s"):
    return kind + "es"
  return kind + "s"

def sort_dicts(d, *, depth=1):
  assert isinstance(d, dict)
  assert depth >= 1
  if depth > 1:
    for value in d.values():
      sort_dicts(value, depth=depth-1)
  for key in sorted(d.keys()):
    d[key] = d.pop(key)

if __name__ == "__main__":
  main()

