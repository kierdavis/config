{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/grub.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "ptolemy";
    cpu = {
      cores = 32;
      intel = true;
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  networking = {
    # Don't auto-configure unspecified interfaces.
    useDHCP = false;
    interfaces.eno1 = {
      useDHCP = true;
    };
    # bridges.guest-bridge = {};

    # Make sure to generate a new ID using:
    #   head -c4 /dev/urandom | od -A none -t x4
    # if this config is used as a reference for a new host!
    hostId = "0d574bdb";
  };
}
