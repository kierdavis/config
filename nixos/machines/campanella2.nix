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
    hostId = "0e6e63bc";
    wifi = false;
    bluetooth = false;

    cpu = {
      cores = 1;
      intel = true;
    };

    fsdevices = {
      root = "/dev/sda";
      swap = "/dev/sdb";
    };

    vpn = {
      clientCert = ../../secret/pki/campanella2.crt;
      clientKey = ../../secret/pki/campanella2.key;
    };
  };

  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "floppy" "sd_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";
}
