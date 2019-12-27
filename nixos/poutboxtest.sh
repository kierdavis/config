#!/bin/sh
set -o errexit -o nounset -o pipefail
nix-build -A poutbox.vm
rm -fv poutbox.qcow2
result/bin/run-poutbox-vm
