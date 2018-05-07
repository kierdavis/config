# Gyroscope is a Raspberry Pi hosting network shares and other services.
# It is named after the album "Gyroscope" by "Boards of Canada".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/raspberry-pi-3.nix
    ../extras/headless.nix
  ];

  machine = {
    name = "gyroscope";
    wifi = false;

    cpu = {
      cores = 4;
    };

    fsdevices = {
      boot = "/dev/disk/by-label/boot0";
      root = "/dev/disk/by-label/root0";
      swap = "/dev/disk/by-label/swap0";
      tmp = "/dev/disk/by-label/tmp0";
    };
  };

  networking.hostId = "abee6add";

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/gyroscope.crt;
    keyFile = "/etc/gyroscope.key";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home0";
    fsType = "ext4";
  };
}
