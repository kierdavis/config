# Inshowha is a VPS hosting network shares.
# It is named after the band "Inshow-ha".

{ config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/proxmox.nix
    ../extras/headless.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "inshowha";
    wifi = false;
    cpu = {
      cores = 2;
      intel = true;
    };
  };

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-part2";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
  # Not enough RAM for a tmpfs
  boot.tmpOnTmpfs = lib.mkForce false;
  boot.cleanTmpDir = true;

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "0a6e2890";

  # From nixos-generate-config.
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # VPN client config.
  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/inshowha.crt;
    keyFile = "/etc/inshowha.key";
  };
}
