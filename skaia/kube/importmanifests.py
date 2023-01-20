#!/usr/bin/env nix-shell
#!nix-shell -p cue -p kubernetes-helm -p "python3.withPackages(py: with py; [ruamel-yaml])" -i python3

import base64
import pathlib
import re
import subprocess
import sys
import tarfile
import tempfile
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
  "stash": {
    "version": "2022.12.11",
    "helm_repo_url": "https://charts.appscode.com/stable/",
    "helm_chart": "stash",
    "helm_version_template": "v{}",
    "helm_dest_namespace": "stash",
    "helm_vars": {
      "features.community": "true",
      "global.license": "PLACEHOLDER",
      "global.skipCleaner": "true",
      "stash-community.nameOverride": "stash",
    },
    "dest_dir": "system/stash",
  },
}

def patch_resource(resource):
  if resource["kind"] == "DaemonSet" and resource["metadata"]["name"] == "calico-node":
    assert resource["spec"]["template"]["spec"]["initContainers"][0]["name"] == "upgrade-ipam"
    del resource["spec"]["template"]["spec"]["initContainers"][0]
    node_container = resource["spec"]["template"]["spec"]["containers"][0]
    assert node_container["name"] == "calico-node"
    del node_container["resources"]["requests"]["cpu"]
    set_env(node_container, "CALICO_IPV4POOL_BLOCK_SIZE", "26")
    set_env(node_container, "CALICO_IPV4POOL_IPIP", "Never")
    set_env(node_container, "CALICO_IPV4POOL_VXLAN", "Never")
    set_env(node_container, "CALICO_IPV4POOL_NAT_OUTGOING", "true")
    set_env(node_container, "CALICO_IPV4POOL_NODE_SELECTOR", "all()")
    set_env(node_container, "CALICO_IPV4POOL_DISABLE_BGP_EXPORT", "false")
    set_env(node_container, "IP_AUTODETECTION_METHOD", "kubernetes-internal-ip")
    set_env(node_container, "IP6_AUTODETECTION_METHOD", "kubernetes-internal-ip")
    setup_dynamic_env(node_container, "CALICO_IPV4POOL_CIDR", desired_index=0)
  if resource["kind"] == "Deployment" and resource["metadata"]["name"] == "metrics-server":
    # x509: cannot validate certificate for 10.88.1.2 because it doesn't contain any IP SANs
    # Unfortunately Talos doesn't seem to have an option to add SANs to the kubelet's certificate.
    assert resource["spec"]["template"]["spec"]["containers"][0]["name"] == "metrics-server"
    resource["spec"]["template"]["spec"]["containers"][0]["args"].append("--kubelet-insecure-tls")
  if resource["kind"] == "Prometheus":
    # I want to override these fields.
    del resource["spec"]["replicas"]
    del resource["spec"]["resources"]["requests"]["memory"]
  if resource["kind"] == "Alertmanager":
    del resource["spec"]["replicas"]
  if resource["kind"] == "Deployment" and resource["metadata"]["name"] == "prometheus-adapter":
    del resource["spec"]["replicas"]
  if resource["kind"] == "DaemonSet" and resource["metadata"]["name"] == "node-exporter":
    del resource["spec"]["template"]["spec"]["priorityClassName"]
  if resource["kind"] == "ConfigMap" and resource["metadata"]["name"] == "rook-ceph-operator-config":
    del resource["data"]["CSI_PROVISIONER_REPLICAS"]
  if resource["kind"] == "Secret" and resource["metadata"]["name"] == "stash-license":
    assert base64.b64decode(resource["data"]["key.txt"]) == b"PLACEHOLDER"
    del resource["data"]["key.txt"]
  if resource["kind"] in ("ValidatingWebhookConfiguration", "MutatingWebhookConfiguration"):
    for webhook in resource.get("webhooks", []):
      ca_bundle = webhook.get("clientConfig", {}).get("caBundle")
      if ca_bundle and base64.b64decode(ca_bundle) == b"not-ca-cert":
        del webhook["clientConfig"]["caBundle"]
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
  component_name = sys.argv[1]
  component = components[component_name]
  component["name"] = component_name
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
  elif "helm_chart" in component:
    with tempfile.TemporaryDirectory(suffix="-helm") as temp_dir:
      temp_dir = pathlib.Path(temp_dir)
      repository_cache_path = temp_dir / "repository-cache"
      repository_config_path = temp_dir / "repositories.yaml"
      with open(repository_config_path, "w") as f:
        YAML().dump({"repositories": [{"name": "myrepo", "url": component["helm_repo_url"]}]}, f)
      base_command = [
        "helm",
        "--kubeconfig=/dev/null",
        f"--repository-config={repository_config_path}",
        f"--repository-cache={repository_cache_path}",
      ]
      subprocess.run(base_command + ["repo", "update"], check=True)
      template_command = base_command + [
        "template",
        component["name"],
        f"myrepo/{component['helm_chart']}",
        f"--version={component['helm_version_template'].format(component['version'])}",
        f"--namespace={component['helm_dest_namespace']}",
      ]
      for key, value in component.get("helm_vars", {}).items():
        template_command.append(f"--set={key}={value}")
      with subprocess.Popen(template_command, stdout=subprocess.PIPE) as process:
        yield from yaml.load_all(process.stdout)
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

