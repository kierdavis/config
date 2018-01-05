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
    sambaClient
  ];

  machine = {
    name = "saelli";
    hostId = "7628944b";
    wifi = true;
    bluetooth = true;

    cpu = {
      cores = 4;
      intel = true;
    };

    fsdevices = {
      root = "/dev/disk/by-uuid/87d22f40-ba26-4b0f-af49-1d08c93522c9";
      efi = "/dev/disk/by-uuid/C2E6-87F4";
      swap = "/dev/disk/by-uuid/d9939f0d-3e6c-439e-a308-e1b40a254b9f";
    };

    i3blocks = {
      cpuThermalZone = "thermal_zone0";
      ethInterface = "enp4s25";
      wlanInterface = "wlp3s0";
    };

    vpn = {
      clientCert = ../../secret/pki/saelli.crt;
      clientKey = ../../secret/pki/saelli.key;
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  powerManagement.cpuFreqGovernor = "powersave";

  # Additional filesystems (LVM).
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/85409f8f-ee42-476c-b68f-edab6b025f3a";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
}
