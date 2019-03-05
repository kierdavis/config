#!/bin/sh
echo >&2 "do not run this script directly; instead review the commands inside and run them by hand."
exit 1

nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=shadowshow-rescue-usb.nix
pv result/iso/*.iso | sudo dd of=/dev/sdc 
sync
