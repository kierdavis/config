# Campanella2 is a VPS hosting network shares and other services.
# It is named after the band "Wednesday Campanella".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/linode.nix
    ../extras/headless.nix
  ];

  machine = {
    name = "campanella2";
    wifi = false;

    cpu = {
      cores = 1;
      intel = true;
    };

    fsdevices = {
      root = "/dev/sda";
      swap = "/dev/sdb";
    };
  };

  networking.hostId = "0e6e63bc";

  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "floppy" "sd_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  campanella-vpn.server = {
    enable = true;
    certFile = ../../secret/pki/campanella2-server.crt;
    keyFile = ../../secret/pki/campanella2-server.key;
  };
}
