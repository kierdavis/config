import argparse
import re
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--depends-on-setup", action="store_true")
parser.add_argument("--url")
args = parser.parse_args()

def subst_resource_block(text):
  text = re.sub(r'(?m)(^\s*)("env" = \[\]\n|"readOnly" = false\n)', r'\1# \2', text)
  if re.search(r'(?m)^    "kind" = "ClusterRole', text):
    text = re.sub(r'(?m)^      "namespace"[^\n]*\n', '', text)
  if re.search(r'"role(binding)?_prometheus_k8s"', text):
    text = re.sub(r'(?m)^    "metadata" = \{\n', '\g<0>      "namespace" = "default"\n', text)
  if re.search(r'"kind" = "Secret"', text):
    text = re.sub(r'(?m)^\}$', r'  computed_fields = ["metadata.labels", "metadata.annotations", "stringData"]\n\g<0>', text)
  if args.depends_on_setup:
    text = re.sub(r'(?m)^\}$', r'  depends_on = [module.setup]\n\g<0>', text)
  return text

resource_blocks = re.findall(r'(?ms)^resource.*?^\}$', sys.stdin.read())
resource_blocks = map(subst_resource_block, resource_blocks)

print(f'# From {args.url}')
for resource_block in resource_blocks:
  print()
  print(resource_block)
