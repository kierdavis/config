#!/bin/sh
set -o errexit -o pipefail -o nounset

name=$1

dir=$PWD/containers/$name

image=$(nix-build --no-out-link $dir/dockerimage.nix)
docker load < $image
docker run $(cat $dir/dockerflags.txt) campanella-$name
