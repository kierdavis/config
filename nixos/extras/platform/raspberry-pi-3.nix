# OUT OF DATE!

{ config, pkgs, lib, ... }:

{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
 
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/boot" = {
    device = config.machine.fsdevices.boot;
    fsType = "vfat";
  };

  boot.tmpOnTmpfs = lib.mkForce false;
  fileSystems."/tmp" = {
    device = config.machine.fsdevices.tmp;
    fsType = "ext4";
  };
}
