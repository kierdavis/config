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

  boot.supportedFilesystems = ["zfs"];
  fileSystems."/" = { device = "ptolemy/os/root"; fsType = "zfs"; };
  fileSystems."/home" = { device = "ptolemy/data/home"; fsType = "zfs"; };
  fileSystems."/nix/store" = { device = "ptolemy/os/nix-store"; fsType = "zfs"; };
  fileSystems."/var/cache" = { device = "ptolemy/transient/cache"; fsType = "zfs"; };
  fileSystems."/var/log" = { device = "ptolemy/os/log"; fsType = "zfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-partlabel/pto_a_boot"; fsType = "ext4"; };
  boot.loader.grub.device = "/dev/sda";
  swapDevices = [
    { device = "/dev/disk/by-partlabel/pto_a_swap"; }
    { device = "/dev/disk/by-partlabel/pto_b_swap"; }
  ];
}
