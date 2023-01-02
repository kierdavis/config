# Coloris is my workstation / gaming PC, built in 2016.
# It is named after the album "Coloris" by "she".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/efi.nix
    # ../extras/boinc.nix
    ../extras/desktop
    ../extras/wifi.nix
    ../extras/audio.nix
    ../extras/devel.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "coloris";
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
  fileSystems.efi.device = "/dev/disk/by-uuid/05BB-9C39";
  systemd.services.boinc.after = [ "var-lib-boinc.mount" ];
  systemd.services.boinc.requires = [ "var-lib-boinc.mount" ];

  # Networking.
  networking.wireless.interfaces = [ "wlp3s0" ];

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "db4d501a";

  # From nixos-generate-config.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbcore" "sd_mod" "sr_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  systemd.services.komi-server = {
    script = "exec ${pkgs.python3}/bin/python -m http.server 9090";
    serviceConfig = {
      User = "kier";
      Group = "users";
      WorkingDirectory = "/home/kier/checkouts/komi";
    };
    wantedBy = ["multi-user.target"];
  };

  services.bird2.enable = true;
  services.bird2.config = ''
    log syslog all;
    router id 192.168.178.135;
    debug protocols { states, routes, filters, interfaces, events };
    protocol device {}
    protocol direct {
      ipv4;
      ipv6;
    }
    protocol kernel kernelipv4 {
      ipv4 { export all; };
    }
    protocol kernel kernelipv6 {
      ipv6 { export all; };
    }
    protocol bgp bgpprospit {
      description "BGP with prospit";
      local as 64604;
      neighbor 192.168.178.2 as 64600;
      direct;
      hold time 10;
      ipv4 {
        import all;
        export all;
      };
      ipv6 {
        import all;
        export all;
      };
    }
  '';
}
