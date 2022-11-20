#!/usr/bin/env nix-shell
#!nix-shell -p cue -p "python3.withPackages(py: with py; [ruamel-yaml])" -i python3

import subprocess
import urllib.request
from ruamel.yaml import YAML

VERSION = "3.24.3"
CUE_PACKAGE = "calico"

def main():
  with urllib.request.urlopen(f"https://raw.githubusercontent.com/projectcalico/calico/v{VERSION}/manifests/calico.yaml") as u:
    with open("imported.yaml", "w") as f:
      with YAML(output=f) as yaml:
        for manifest in yaml.load_all(u):
          hack_manifest(manifest)
          yaml.dump(manifest)
  subprocess.run(
    [
      "cue", "import",
      "--with-context",
      "-l", '"resources"',
      "-l", '"\\(strings.ToLower(data.kind))s"',
      "-l", '"\\(data.metadata.namespace & string)"',
      "-l", "data.metadata.name",
      "--package", CUE_PACKAGE,
      "--force",
      "imported.yaml",
    ],
    check=True,
  )
  with open("imported.cue", "r") as f:
    cue_text = f.read()
  cue_text = cue_text.replace('"<<<podNetworkCidr>>>"', 'podNetworkCidr')
  with open("imported.cue", "w") as f:
    f.write(cue_text)
  subprocess.run(["cue", "fmt", "imported.cue"], check=True)

def hack_manifest(manifest):
  if manifest["kind"] == "DaemonSet" and manifest["metadata"]["name"] == "calico-node":
    assert manifest["spec"]["template"]["spec"]["initContainers"][0]["name"] == "upgrade-ipam"
    del manifest["spec"]["template"]["spec"]["initContainers"][0]
    node_container = manifest["spec"]["template"]["spec"]["containers"][0]
    assert node_container["name"] == "calico-node"
    set_env(node_container, "CALICO_IPV4POOL_CIDR", "<<<podNetworkCidr>>>")
    set_env(node_container, "CALICO_IPV4POOL_BLOCK_SIZE", "26")
    set_env(node_container, "CALICO_IPV4POOL_IPIP", "Never")
    set_env(node_container, "CALICO_IPV4POOL_VXLAN", "Never")
    set_env(node_container, "CALICO_IPV4POOL_NAT_OUTGOING", "true")
    set_env(node_container, "CALICO_IPV4POOL_NODE_SELECTOR", "all()")
    set_env(node_container, "CALICO_IPV4POOL_DISABLE_BGP_EXPORT", "false")

def set_env(container, name, value):
  for env in container["env"]:
    if env["name"] == name:
      env["value"] = value
      return
  container["env"].append({
    "name": name,
    "value": value,
  })

if __name__ == "__main__":
  main()
