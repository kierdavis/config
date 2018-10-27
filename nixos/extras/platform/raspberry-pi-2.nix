# OUT OF DATE!

{ config, pkgs, lib, ... }:

{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
 
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # !!! This is only for ARMv6 / ARMv7. Don't enable this on AArch64, cache.nixos.org works there.
  nix.binaryCaches = lib.mkForce [ "http://nixos-arm.dezgeg.me/channel" ];
  nix.binaryCachePublicKeys = [ "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%" ];

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
