# Ouroboros is an Asus gaming laptop from 2013.
# It is named after (a transliteration of) the song "ウロボロス" by "death's dynamic shroud.wmv".

{ config, lib, pkgs, ... }:

let
  localPkgs = import ../../pkgs pkgs;

  samba = import ../samba.nix;
  sambaClient = samba.client {
    host = "nocturn";
    port = 445;
  };
in

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

    vpn = {
      clientCert = ../../secret/pki/ouroboros.crt;
      clientKey = ../../secret/pki/ouroboros.key;
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # Additional filesystems (ZFS).
  fileSystems."/home" = {
    device = "ouroboros_lin_home/home";
    fsType = "zfs";
    options = ["noatime" "nodiratime"];
  };
}
