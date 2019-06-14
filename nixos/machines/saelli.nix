# Saelli is a Thinkpad T440s, bought second-hand in 2018.
# It is named after the song "Saelli" by "Corpo-Mente".

let
  cascade = import ../cascade.nix;

in { config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/efi.nix
    ../extras/desktop
    ../extras/low-power.nix
    ../extras/clickpad.nix
    ../extras/devel.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "saelli";
    wifi = true;
    ipv6-internet = false;
    cpu = {
      cores = 4;
      intel = true;
    };
    i3blocks = {
      cpuThermalZone = "thermal_zone0";
      ethInterface = "enp4s25";
      wlanInterface = "wlp3s0";
      batteries = [ "BAT0" "BAT1" ];
    };
  };

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/41a55911-8a7e-45f3-8a55-116b9abb4f6e";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9cba21a0-ced6-4511-bfd2-5e576d02915a";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/d9939f0d-3e6c-439e-a308-e1b40a254b9f"; } ];
  fileSystems.efi.device = "/dev/disk/by-uuid/5036-1CC7";

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "7628944b";

  # From nixos-generate-config.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  powerManagement.cpuFreqGovernor = "powersave";

  # VPN client config.
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${cascade.addrs.cv.saelli}/112" ];
    listenPort = cascade.vpn.port;
    privateKeyFile = "/etc/cascade.wg-priv-key";
    peers = [
      {
        publicKey = "rCt64U6gNe10TK7SRhaNd/ePuzhiLKW2IAJKSHTQKE4=";
        endpoint = "${cascade.addrs.pub4.campanella2}:${toString cascade.vpn.port}";
        allowedIPs = [
          "${cascade.addrs.cv.campanella2}/112"
          "${cascade.addrs.cl.altusanima}/112"
          "${cascade.addrs.cvl.altusanima}/112"
        ];
        persistentKeepalive = 25;
      }
    ];
  };
  networking.firewall.allowedUDPPorts = [ cascade.vpn.port ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "eduroam" ''
      set -o errexit -o nounset
      sudo ${pkgs.gnused}/bin/sed -i -E '/${lib.concatStringsSep "|" config.networking.nameservers}/d' /etc/resolv.conf
    '')
  ];
}
