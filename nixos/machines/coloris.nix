# Coloris is my workstation / gaming PC, built in 2016.
# It is named after the album "Coloris" by "she".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/efi.nix
    ../extras/boinc.nix
    ../extras/desktop
    ../extras/devel.nix
    ../extras/netfs/cherry.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "coloris";
    wifi = true;
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
  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/842e7d6c-cc65-4719-89b4-3968b8bfb30d";
    fsType = "ext4";
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/afd2e652-b34e-4543-95c3-e2fc5df22201"; } ];
  fileSystems.efi.device = "/dev/disk/by-uuid/6F09-65AE";
  systemd.services.boinc.after = [ "var-lib-boinc.mount" ];
  systemd.services.boinc.requires = [ "var-lib-boinc.mount" ];
  systemd.services.docker.after = [ "var-lib-docker.mount" ];
  systemd.services.docker.requires = [ "var-lib-docker.mount" ];

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "db4d501a";

  # From nixos-generate-config.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbcore" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # VPN client config.
  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/coloris.crt;
    keyFile = "/etc/coloris.key";
  };

  # Keyboard/mouse driver.
  hardware.ckb-next.enable = true;
  # https://github.com/mattanger/ckb-next#linux
  boot.kernelParams = [ "usbhid.quirks=0x1B1C:0x1B15:0x20000408,0x1B1C:0x1B2F:0x20000408" ];

  # Monitor layout.
  services.xserver.xrandrHeads = ["DP-0" "HDMI-0"];

  # Fix keyboard layout.
  # Since https://gitlab.freedesktop.org/xorg/driver/xf86-input-evdev/commit/192fdb06905f0f190e3a0e258919676934e6633c
  # my keyboard has a US layout on startup instead of a UK one (as is already specified by services.xserver.layout).
  # Updating the keyboard layout with setxkbmap is a workaround, but it doesn't fix the underlying problem, which
  # is probably related to interaction between ckb-next (the driver), xf86-input-evdev (X11's input module) and
  # /dev/input/* (kernel input event stuff).
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap ${config.services.xserver.layout}
  '';
}
