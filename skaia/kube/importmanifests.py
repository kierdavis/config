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
  "prometheus": {
    "version": "0.11.0",
    "tar_url": "https://github.com/prometheus-operator/kube-prometheus/archive/refs/tags/v{version}.tar.gz",
    "tar_member_regexp": r"^[^/]*/manifests/",
    "dest_dir": "system/prometheus",
  },
}

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
  manual_cue_path = dest_dir / f"{cue_package}.cue"
  if not manual_cue_path.exists():
    manual_cue_path.write_text(MANUAL_CUE_TEMPLATE.format(cue_package=cue_package).lstrip("\n"))

def fetch_resources(component, yaml):
  if "tar_url" in component:
    tar_url = component["tar_url"].format(**component)
    with urllib.request.urlopen(tar_url) as tar_fileobj:
      with tarfile.open(fileobj=tar_fileobj, mode="r|gz") as tar:
        for tar_member in tar:
          if tar_member.isreg() and re.match(component["tar_member_regexp"], tar_member.name):
            yield from yaml.load_all(tar.extractfile(tar_member))
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

MANUAL_CUE_TEMPLATE = """
package {cue_package}

import (
\t"cue.skaia/kube/schema"
)

resources: schema.resources
"""

if __name__ == "__main__":
  main()

