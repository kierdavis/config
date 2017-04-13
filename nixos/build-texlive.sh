#!/bin/sh
set -eu

nixpkgs=/etc/nixos/nixpkgs
log=/tmp/nix-build.log
cache=/mnt/nocturn/nix-cache
secret_key=/etc/nix/nix-cache.sec

nix-build --no-out-link $nixpkgs -A texlive.combined.scheme-full | tee $log

paths=$(tail -1 $log)

nix-push --dest $cache --bzip2 --key-file $secret_key $paths

rm -f $log
