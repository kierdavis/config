let
  samba = import ../samba.nix;
  sambaClient = samba.client {
    host = "82.9.123.20";
    port = 9092;
  };
in

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/boot-efi.nix
    ../extras/desktop
    sambaClient
  ];

  machine = {
    name = "ouroboros";
    hostId = "8e8cad01";
    vboxHost = true;
    wifi = true;
    bluetooth = true;

    cpu = {
      cores = 4;
      intel = true;
    };

    fsdevices = {
      root = "/dev/disk/by-uuid/97678c8a-538a-4034-b725-72ced3f0759d";
      efi = "/dev/disk/by-uuid/DBAA-F84C";
      swap = "/dev/disk/by-uuid/09cf9635-7fab-41a1-9abc-32b474bc101d";
    };

    i3blocks = {
      cpuThermalZone = "thermal_zone0";
      ethInterface = "enp4s0";
      wlanInterface = "wlp3s0";
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "powersave";

  # Additional filesystems (ZFS).
  fileSystems."/home" = {
    device = "ouroboros_lin_home/home";
    fsType = "zfs";
    options = ["noatime" "nodiratime"];
  };
}
