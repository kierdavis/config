# Ouroboros is an Asus gaming laptop from 2013.
# It is named after (a transliteration of) the song "ウロボロス" by "death's dynamic shroud.wmv".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/efi.nix
    ../extras/desktop
    ../extras/devel.nix
    ../extras/netfs/gyroscope.nix
  ];

  machine = {
    name = "ouroboros";
    wifi = true;

    cpu = {
      cores = 4;
      intel = true;
    };

    gpu = {
      nvidia = true;
    };

    i3blocks = {
      cpuThermalZone = "thermal_zone0";
      ethInterface = "enp4s0";
      wlanInterface = "wlp3s0";
    };
  };

  networking.hostId = "8e8cad01";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # Additional filesystems (ZFS).
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/97678c8a-538a-4034-b725-72ced3f0759d";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/home" = {
    device = "ouroboros_lin_home/home";
    fsType = "zfs";
    options = ["noatime" "nodiratime"];
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/09cf9635-7fab-41a1-9abc-32b474bc101d"; } ];
  fileSystems.efi.device = "/dev/disk/by-uuid/DBAA-F84C";

  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/ouroboros.crt;
    keyFile = "/etc/ouroboros.key";
  };
}
