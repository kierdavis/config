#!/bin/sh
set -o errexit -o nounset -o pipefail
result=$(nix-build -A poutbox.vm --no-out-link)
rm -fv poutbox.qcow2
export QEMU_OPTS="-serial stdio -device usb-ehci,id=ehci -device usb-host,hostbus=2,hostaddr=4,bus=ehci.0"
$result/bin/run-poutbox-vm
