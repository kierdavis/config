#!/bin/sh
set -eu

attrs=""

for arg in $*; do
  attrs="$attrs -A $arg"
done

if [ -z "$attrs" ]; then
  echo "no attributes supplied (try '$0 all')"
  exit 2
fi

config=/home/kier/config
log=/tmp/nix-build.log
cache=/mnt/nocturn/nix-cache
secret_key=/etc/nix/nix-cache.sec

nix-build -Q --no-out-link $config/nixos $attrs | tee $log

paths=$(tail $log | grep '^/nix/store')

echo "**************************"
echo "Deploying roots:"
for path in $paths; do
  echo "  $path"
done
echo "**************************"

nix-push --dest $cache --bzip2 --key-file $secret_key $paths

rm -f $log
