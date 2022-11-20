#!/usr/bin/env nix-shell
#!nix-shell -p cue -p "python3.withPackages(py: with py; [ruamel-yaml])" -i python3

import subprocess
import urllib.request
from ruamel.yaml import YAML

VERSION = "0.6.1"
CUE_PACKAGE = "metricsserver"

def main():
  with urllib.request.urlopen(f"https://github.com/kubernetes-sigs/metrics-server/releases/download/v{VERSION}/components.yaml") as u:
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
  subprocess.run(["cue", "fmt", "imported.cue"], check=True)

def hack_manifest(manifest):
  if manifest["kind"] == "Deployment" and manifest["metadata"]["name"] == "metrics-server":
    # x509: cannot validate certificate for 10.88.1.2 because it doesn't contain any IP SANs
    # Unfortunately Talos doesn't seem to have an option to add SANs to the kubelet's certificate.
    manifest["spec"]["template"]["spec"]["containers"][0]["args"].append("--kubelet-insecure-tls")

if __name__ == "__main__":
  main()
