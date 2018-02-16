{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  fileSystems.efi = {
    mountPoint = config.boot.loader.efi.efiSysMountPoint;
    device = config.machine.fsdevices.efi;
    fsType = "vfat";
    options = ["noatime" "nodiratime"];
  };
}
