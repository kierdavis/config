#!/bin/sh
set -eu

config=/home/kier/config
log=/tmp/nix-build.log
cache=/mnt/nocturn/nix-cache
secret_key=/etc/nix/nix-cache.sec

nix-build $config/nixos -A coloris.system -A ouroboros.system -A nocturn.system | tee $log

paths=$(tail -3 $log)

nix-push --dest $cache --bzip2 --key-file $secret_key $paths

rm -f $log
