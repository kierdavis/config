# OUT OF DATE!

# Solanin is a Raspberry Pi hosting network shares and other services.
# It is named after the album "Solanin" by "Mere".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/raspberry-pi-2.nix
    ../extras/headless.nix
  ];

  machine = {
    name = "solanin";
    wifi = false;

    cpu = {
      cores = 4;
    };

    fsdevices = {
      boot = "/dev/disk/by-uuid/2178-694E";
      root = "/dev/disk/by-uuid/80ceb00c-04bd-4097-85c3-d6e62bfc45ce";
      swap = "/dev/disk/by-uuid/10042251-2043-4e76-b651-82a72afa6f2b";
      tmp = "/dev/disk/by-uuid/0dceee97-79df-4c80-9de0-311504167c1b";
    };
  };

  networking.hostId = "42b124c7";

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/solanin.crt;
    keyFile = "/etc/solanin.key";
  };
}
