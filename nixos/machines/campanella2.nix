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
      root = "/dev/disk/by-uuid/819cb8e9-a122-4aa3-8248-d5132f5ae5fb";
      swap = "/dev/disk/by-uuid/0679e6a0-a6b5-457b-b599-7eb929642413";
    };

    vpn = {
      clientCert = ../../secret/pki/campanella2.crt;
      clientKey = ../../secret/pki/campanella2.key;
    };
  };

  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "floppy" "sd_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";
}
