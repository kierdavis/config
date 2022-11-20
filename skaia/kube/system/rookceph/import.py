#!/usr/bin/env nix-shell
#!nix-shell -p cue -p "python3.withPackages(py: with py; [ruamel-yaml])" -i python3

import subprocess
import urllib.request
from ruamel.yaml import YAML

VERSION = "1.10.6"
CUE_PACKAGE = "rookceph"

def main():
  with open("imported.yaml", "w") as f:
    with YAML(output=f) as yaml:
      for component in ["common", "crds", "operator", "toolbox"]:
        with urllib.request.urlopen(f"https://raw.githubusercontent.com/rook/rook/v{VERSION}/deploy/examples/{component}.yaml") as u:
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
  subprocess.run(["cue", "fmt", "imported.cue"], check=True)

def hack_manifest(manifest):
  pass

if __name__ == "__main__":
  main()

