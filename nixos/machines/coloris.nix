# Coloris is my workstation / gaming PC, built in 2016.
# It is named after the album "Coloris" by "she".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/efi.nix
    ../extras/boinc.nix
    ../extras/desktop
    ../extras/audio.nix
    ../extras/devel.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "coloris";
    wifi = true;
    ipv6-internet = false;
    cpu = {
      cores = 4;
      intel = true;
    };
    gpu = {
      nvidia = true;
    };
    i3blocks = {
      cpuThermalZone = "thermal_zone2";
      ethInterface = "enp4s0";
      wlanInterface = "wlp3s0";
    };
  };

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/059315e0-e130-475c-9d84-45e4ef750a6b";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7ea83533-f78b-4deb-94ed-6bef5dbfa8e4";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems.boinc = {
    mountPoint = config.services.boinc.dataDir;
    device = "/dev/disk/by-uuid/f25c297c-46ff-45c6-96f0-d645931b3a67";
    fsType = "ext4";
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/afd2e652-b34e-4543-95c3-e2fc5df22201"; } ];
  fileSystems.efi.device = "/dev/disk/by-uuid/6F09-65AE";
  systemd.services.boinc.after = [ "var-lib-boinc.mount" ];
  systemd.services.boinc.requires = [ "var-lib-boinc.mount" ];

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "db4d501a";

  # From nixos-generate-config.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbcore" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # Keyboard/mouse driver.
  hardware.ckb-next.enable = true;
  # https://github.com/mattanger/ckb-next#linux
  boot.kernelParams = [ "usbhid.quirks=0x1B1C:0x1B15:0x20000408,0x1B1C:0x1B2F:0x20000408" ];

  services.printing = {
    enable = true;
    drivers = [
      pkgs.gutenprint
      pkgs.cups-brother-hl1110
      pkgs.hplip
    ];
  };

  systemd.services.komi-server = {
    script = "exec ${pkgs.python3}/bin/python -m http.server 9090";
    serviceConfig = {
      User = "kier";
      Group = "users";
      WorkingDirectory = "/home/kier/checkouts/komi";
    };
    wantedBy = ["multi-user.target"];
  };
}
