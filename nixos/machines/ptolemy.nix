let
  hpFirmwareModule = { config, lib, pkgs, ... }: let
    sources = [
      (pkgs.fetchurl {
        # https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_7add8906345a4e7f982bd39f31
        url = "https://downloads.hpe.com/pub/softlib2/software1/sc-linux-fw-sys/p244945965/v167882/RPMS/i386/firmware-system-p73-2019.05.24-1.1.i386.rpm";
        sha256 = "d2b07f1b3c209e338c6c38c3c1a24f359f1563b7ce8b1241ecf357391e6a1f71";
      })
    ];
    sourceDir = pkgs.runCommand "hpfirmware-sources" { inherit sources; } ''
      mkdir -p $out
      for source in $sources; do
        cp -L $source $out/$(basename $source | cut -d- -f2-)
      done
    '';
  in {
    virtualisation.oci-containers.containers.hpfirmware = {
      image = "docker.io/library/centos:7";
      cmd = ["sleep" "infinity"];
      volumes = [
        "/guest/hpfirmware/data:/data:rw"
        "${sourceDir}:/sources:ro"
      ];
      workdir = "/data";
    };
    fileSystems."/guest/hpfirmware/data" = {
      device = "ptolemy/data/hpfirmware-container";
      fsType = "zfs";
    };
    systemd.services."${config.virtualisation.oci-containers.backend}-hpfirmware" = {
      requires = [ "guest-hpfirmware-data.mount" ];
      after = [ "guest-hpfirmware-data.mount" ];
      serviceConfig.StandardOutput = lib.mkForce "journal";
      serviceConfig.StandardError = lib.mkForce "journal";
    };
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/headless.nix
    ../extras/platform/grub.nix
    hpFirmwareModule
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
    "/var/log" = { device = "ptolemy/os/log"; fsType = "zfs"; };
  };
  boot.loader.grub.device = "/dev/sda";
  swapDevices = [
    { device = "/dev/disk/by-partlabel/pto_a_swap"; }
    { device = "/dev/disk/by-partlabel/pto_b_swap"; }
  ];
  boot.tmpOnTmpfs = false;

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";
}
