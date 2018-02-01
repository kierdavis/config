# Saelli is a Thinkpad T440s, bought second-hand in 2018.
# It is named after the song "Saelli" by "Corpo-Mente".

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
    ../extras/low-power.nix
    ../extras/clickpad.nix
    sambaClient
  ];

  machine = {
    name = "saelli";
    hostId = "7628944b";
    wifi = true;
    bluetooth = false;

    cpu = {
      cores = 4;
      intel = true;
    };

    fsdevices = {
      root = "/dev/disk/by-uuid/41a55911-8a7e-45f3-8a55-116b9abb4f6e";
      efi = "/dev/disk/by-uuid/5036-1CC7";
      swap = "/dev/disk/by-uuid/d9939f0d-3e6c-439e-a308-e1b40a254b9f";
    };

    i3blocks = {
      cpuThermalZone = "thermal_zone0";
      ethInterface = "enp4s25";
      wlanInterface = "wlp3s0";
      batteries = [ "BAT0" "BAT1" ];
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  powerManagement.cpuFreqGovernor = "powersave";

  # Additional filesystems (LVM).
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9cba21a0-ced6-4511-bfd2-5e576d02915a";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };

  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/pki/saelli.crt;
    keyFile = ../../secret/pki/saelli.key;
  };
}
