#!/bin/sh
set -o errexit -o nounset -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

version="$1"
tag="v$version"
checkout=/tmp/prometheus
if [[ -e "$checkout" ]]; then
  git -C "$checkout" fetch --tags
else
  git clone --branch "$tag" "git@github.com:prometheus-operator/kube-prometheus.git" "$checkout"
fi
git -C "$checkout" reset --hard
git -C "$checkout" checkout "$tag"

for subdir in "setup" "."; do
  for f in "$subdir"/*.tf; do
    if [[ "$f" != */main.tf ]]; then
      rm -f "$f"
    fi
  done

  for src in "$checkout"/manifests/"$subdir"/*.yaml; do
    if [[ "$src" != *networkPolicy* ]]; then
      src_basename="${src##*/}"
      dest="$subdir/${src_basename/.yaml/.tf}"
      args="--url https://github.com/prometheus-operator/kube-prometheus/blob/$tag/${src#$checkout/}"
      if [[ "$subdir" = . ]]; then
        args="$args --depends-on-setup"
      fi
      tfk8s --strip < "$src" | python3 pull.subst.py $args > "$dest"
    fi
  done
done
