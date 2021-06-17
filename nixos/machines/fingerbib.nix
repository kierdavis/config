{ config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/headless.nix
    ../extras/platform/grub.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "fingerbib";
    cpu = {
      cores = 8;
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

    # Make sure to generate a new ID using:
    #   head -c4 /dev/urandom | od -A none -t x4
    # if this config is used as a reference for a new host!
    hostId = "74e71470";
  };

  boot.supportedFilesystems = ["zfs"];
  fileSystems = {
    "/" = { device = "fingerbib/os/root"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/fb_boot1"; fsType = "ext4"; };
    "/home" = { device = "fingerbib/data/home"; fsType = "zfs"; };
    "/nix/store" = { device = "fingerbib/os/nix-store"; fsType = "zfs"; };
    "/tmp" = { device = "fingerbib/transient/tmp"; fsType = "zfs"; };
    "/var/cache" = { device = "fingerbib/transient/cache"; fsType = "zfs"; };
    "/var/log" = { device = "fingerbib/os/log"; fsType = "zfs"; };
  };
  boot.loader.grub.device = "/dev/disk/by-id/ata-ST2000DL003-9VT166_5YD5YEPX";
  swapDevices = [
    { device = "/dev/disk/by-partlabel/fb_swap"; }
  ];
  boot.tmpOnTmpfs = false;
}
