# Coloris is my workstation / gaming PC, built in 2016.
# It is named after the album "Coloris" by "she".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/efi.nix
    ../extras/boinc.nix
    ../extras/desktop
    ../extras/devel.nix
    ../extras/netfs/gyroscope.nix
  ];

  machine = {
    name = "coloris";
    wifi = true;

    cpu = {
      cores = 4;
      intel = true;
    };

    gpu = {
      nvidia = true;
    };

    i3blocks = {
      cpuThermalZone = "thermal_zone2";
      ethInterface = "enp4s0";
      wlanInterface = "wlp3s0";
    };
  };

  networking.hostId = "db4d501a";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbcore" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  hardware.ckb.enable = true;

  # https://github.com/mattanger/ckb-next#linux
  boot.kernelParams = [ "usbhid.quirks=0x1B1C:0x1B15:0x20000408,0x1B1C:0x1B2F:0x20000408" ];

  services.xserver.xrandrHeads = ["DP-0" "HDMI-0"];

  # Additional filesystems (LVM).
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/059315e0-e130-475c-9d84-45e4ef750a6b";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7ea83533-f78b-4deb-94ed-6bef5dbfa8e4";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems.boinc = {
    mountPoint = config.services.boinc.dataDir;
    device = "/dev/disk/by-uuid/f25c297c-46ff-45c6-96f0-d645931b3a67";
    fsType = "ext4";
  };
  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/842e7d6c-cc65-4719-89b4-3968b8bfb30d";
    fsType = "ext4";
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/afd2e652-b34e-4543-95c3-e2fc5df22201"; } ];
  fileSystems.efi.device = "/dev/disk/by-uuid/6F09-65AE";
  systemd.services.docker.after = [ "var-lib-docker.mount" ];

  environment.systemPackages = [
    pkgs.boincgpuctl
    pkgs.google-musicmanager
  ];

  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/coloris.crt;
    keyFile = "/etc/coloris.key";
  };
}
