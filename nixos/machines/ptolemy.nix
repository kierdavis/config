{ config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/headless.nix
    ../extras/platform/grub.nix
    ../extras/platform/hp.nix
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
  fileSystems = {
    "/" = { device = "ptolemy/os/root"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/pto_a_boot"; fsType = "ext4"; };
    "/home" = { device = "ptolemy/data/home"; fsType = "zfs"; };
    "/nix/store" = { device = "ptolemy/os/nix-store"; fsType = "zfs"; };
    "/tmp" = { device = "ptolemy/transient/tmp"; fsType = "zfs"; };
    "/var/cache" = { device = "ptolemy/transient/cache"; fsType = "zfs"; };
    "/var/lib/containers" = { device = "ptolemy/os/containers"; fsType = "zfs"; };
    "/var/lib/sum/baseline" = { device = "ptolemy/transient/hpsum-baseline"; fsType = "zfs"; };
    "/var/log" = { device = "ptolemy/os/log"; fsType = "zfs"; };
  };
  boot.loader.grub.device = "/dev/sda";
  swapDevices = [
    { device = "/dev/disk/by-partlabel/pto_a_swap"; }
    { device = "/dev/disk/by-partlabel/pto_b_swap"; }
  ];
  boot.tmpOnTmpfs = false;
  systemd.services."${config.virtualisation.oci-containers.backend}-hpsum" = {
    requires = [ "var-lib-sum-baseline.mount" ];
    after = [ "var-lib-sum-baseline.mount" ];
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  services.icingaweb2 = {
    enable = true;
    timezone = config.time.timeZone;
  };

  # TODO TODO TODO
  networking.firewall.enable = false;
}
