# Butterfly is a server running kubernetes.
# It is named after the song Butterfly by Swingrowers.

{ config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/efi.nix
    ../extras/headless.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "butterfly";
    wifi = false;
    ipv6-internet = true;
    cpu = {
      cores = 8;
      intel = true;
    };
  };

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/disk/by-label/bfy_root";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-label/bfy_home";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-label/bfy_docker";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems.efi.device = "/dev/disk/by-label/bfy_efi";
  boot.loader.grub.device = "/dev/disk/by-id/usb-Generic_Flash_Disk_FEB9E43C-0:0";

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "45f7886d";

  boot.initrd.availableKernelModules = [ "ahci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # XXX hack, this should be made optional
  services.syncthing.enable = lib.mkForce false;
}
