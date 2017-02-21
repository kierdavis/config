let
  samba = import ../samba.nix;
  sambaClient = samba.client {
    host = "192.168.1.24";
    port = 445;
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
    name = "coloris";
    hostId = "db4d501a";
    vboxHost = true;
    wifi = true;
    bluetooth = true;

    cpu = {
      cores = 4;
      intel = true;
    };

    fsdevices = {
      root = "/dev/disk/by-uuid/059315e0-e130-475c-9d84-45e4ef750a6b";
      efi = "/dev/disk/by-uuid/6F09-65AE";
      swap = "/dev/disk/by-uuid/afd2e652-b34e-4543-95c3-e2fc5df22201";
    };

    i3blocks = {
      cpuThermalZone = "thermal_zone2";
      ethInterface = "enp4s0";
      wlanInterface = "wlp3s0";
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbcore" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "powersave";

  hardware.ckb.enable = true;

  services.xserver.xrandrHeads = ["DP-4" "HDMI-0"];

  # Additional filesystems (ZFS).
  fileSystems."/home" = {
    device = "coloris_lin_home/home";
    fsType = "zfs";
    options = ["noatime" "nodiratime"];
  };

  environment.systemPackages = [
    pkgs.google-musicmanager
    pkgs.keybase
  ];
}
