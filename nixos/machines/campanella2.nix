# Campanella2 is a VPS hosting network shares and other services.
# It is named after the band "Wednesday Campanella".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/linode.nix
    ../extras/headless.nix
    ../extras/netfs/gyroscope.nix
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

  fileSystems."/home" = {
    device = "/dev/sdc";
    fsType = "ext4";
  };
  fileSystems."/srv" = {
    device = "/dev/sde";
    fsType = "ext4";
  };

  campanella-vpn.server = {
    enable = true;
    certFile = ../../secret/vpn/certs/campanella2.crt;
    keyFile = "/etc/campanella2.key";
  };
}
