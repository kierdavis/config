{ config, pkgs, lib, ... }:

{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
 
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.tmpOnTmpfs = lib.mkForce false;

  services.xserver.videoDrivers = ["fbdev"];

  nix.gc.automatic = false;
}
