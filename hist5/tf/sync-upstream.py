#!/usr/bin/env nix-shell
#!nix-shell -p "python3.withPackages(ps: with ps;[pyyaml])" -i python3

import argparse
import pathlib
import re
import subprocess
import sys
import yaml

def main():
  components = {
    "prometheus": do_prometheus,
    "rook-ceph": do_rook_ceph,
  }
  parser = argparse.ArgumentParser()
  parser.add_argument("component", choices=set(components.keys()))
  parser.add_argument("version")
  args = parser.parse_args()
  components[args.component](args)

def do_prometheus(args):
  git_clone_url = "git@github.com:prometheus-operator/kube-prometheus.git"
  git_browse_url = "https://github.com/prometheus-operator/kube-prometheus"
  git_tag = f"v{args.version}"
  checkout = pathlib.Path("/tmp/prometheus")
  git_checkout(git_clone_url, checkout, git_tag)
  for subdir in ["setup", "."]:
    src_dir = checkout / "manifests" / subdir
    dest_dir = pathlib.Path(__file__).parent / "prometheus" / "upstream" / subdir
    for child in (dest_dir / subdir).glob("*.tf"):
      if child.name != "main.tf":
        child.unlink()
    for src in src_dir.glob("*.yaml"):
      if src.match("*networkPolicy*") or src.match("*-prometheus.*") or src.match("*-alertmanager.*") or src.match("*/grafana-config.*"):
        continue
      dest = dest_dir / src.with_suffix(".tf").name
      print(src, "->", dest, file=sys.stderr)
      yaml_text = src.read_text()
      if not src.match("*/0alertmanagerConfigCustomResourceDefinition.*"):  # doesn't parse
        yaml_text = fixup_prometheus_yaml(yaml_text)
      tf_text = tfk8s(yaml_text)
      tf_text = fixup_prometheus_tf(tf_text, depends_on_setup=subdir==".")
      tf_text = f"# From {git_browse_url}/blob/{git_tag}/{src.relative_to(checkout)}\n\n" + tf_text
      dest.write_text(tf_text)

def do_rook_ceph(args):
  git_clone_url = "git@github.com:rook/rook.git"
  git_browse_url = "https://github.com/rook/rook"
  git_tag = f"v{args.version}"
  checkout = pathlib.Path("/tmp/rook")
  git_checkout(git_clone_url, checkout, git_tag)
  src_dir = checkout / "deploy" / "examples"
  dest_dir = pathlib.Path(__file__).parent / "rook_ceph" / "upstream"
  for child in dest_dir.glob("*.tf"):
    if child.name != "main.tf":
      child.unlink()
  for stem in ["common", "crds", "operator", "toolbox", "monitoring/rbac", "monitoring/service-monitor"]:
    src = src_dir / (stem + ".yaml")
    dest = dest_dir / (stem.replace("/", "-") + ".tf")
    print(src, "->", dest, file=sys.stderr)
    yaml_text = src.read_text()
    yaml_text = fixup_rook_ceph_yaml(yaml_text)
    tf_text = tfk8s(yaml_text)
    tf_text = fixup_rook_ceph_tf(tf_text)
    tf_text = f"# From {git_browse_url}/blob/{git_tag}/{src.relative_to(checkout)}\n\n" + tf_text
    dest.write_text(tf_text)

def fixup_prometheus_yaml(text):
  resources = [x for x in yaml.safe_load_all(text) if x is not None]
  for resource in resources:
    if resource["kind"] == "Deployment":
      fixup_pod_spec(resource.get("spec", {}).get("template", {}).get("spec", {}))
    if resource["kind"] in ("ClusterRole", "ClusterRoleBinding"):
      resource.get("metadata", {}).pop("namespace", None)
    if resource["kind"] == "Service" and resource["metadata"]["name"] == "grafana":
      [http_port] = [p for p in resource["spec"]["ports"] if p["name"] == "http"]
      http_port["port"] = 80
    if resource["kind"] == "Deployment" and resource["metadata"]["name"] in ["grafana", "kube-state-metrics", "prometheus-operator"]:
      resource["spec"]["template"]["spec"]["priorityClassName"] = "observability-critical"
  return yaml.safe_dump_all(resources)

def fixup_prometheus_tf(text, depends_on_setup):
  def subst_resource_block(text):
    if re.search(r'"role(binding)?_prometheus_k8s"', text):
      text = re.sub(r'(?m)^    "metadata" = \{\n', '\g<0>      "namespace" = "default"\n', text)
    if re.search(r'"kind" = "Secret"', text):
      text = re.sub(r'(?m)^\}$', r'  computed_fields = ["metadata.labels", "metadata.annotations", "stringData"]\n\g<0>', text)
    if depends_on_setup:
      text = re.sub(r'(?m)^\}$', r'  depends_on = [module.setup]\n\g<0>', text)
    return text
  resource_blocks = re.findall(r'(?ms)^resource.*?^\}\n', text)
  resource_blocks = map(subst_resource_block, resource_blocks)
  return "\n".join(resource_blocks)

def fixup_rook_ceph_yaml(text):
  resources = [x for x in yaml.safe_load_all(text) if x is not None]
  for resource in resources:
    if resource["kind"] == "Deployment" and resource["metadata"]["name"] == "rook-ceph-operator":
      resource["spec"]["template"]["spec"]["priorityClassName"] = "system-cluster-critical"
    if resource["kind"] == "RoleBinding":
      for subject in resource["subjects"]:
        if subject["kind"] == "ServiceAccount" and subject["name"] == "prometheus-k8s" and subject["namespace"] == "rook-ceph":
          subject["namespace"] = "monitoring"
  return yaml.safe_dump_all(resources)

def fixup_rook_ceph_tf(text):
  text = re.sub(r"(?m)^( *)(EOT)(,)$", r"\g<1>\g<2>\n\g<1>\g<3>", text)
  return text

def fixup_pod_spec(spec):
  for container in spec.get("containers", []):
    if container.get("env") == []:
      del container["env"]
    for volume_mount in container.get("volumeMounts", []):
      if volume_mount.get("readOnly") is False:
        del volume_mount["readOnly"]

def git_checkout(url, path, tag):
  if path.exists():
    run(["git", "-C", path, "fetch", "--tags"])
  else:
    run(["git", "clone", url, path])
  run(["git", "-C", path, "reset", "--hard"])
  run(["git", "-C", path, "checkout", tag])

def tfk8s(yaml_text):
  return run(["tfk8s", "--strip"], input=yaml_text, stdout=subprocess.PIPE).stdout

def run(command, **kwargs):
  command = [str(word) for word in command]
  kwargs.setdefault("check", True)
  kwargs.setdefault("encoding", "utf-8")
  return subprocess.run(command, **kwargs)

if __name__ == "__main__":
  main()
