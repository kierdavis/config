# Saelli is a Thinkpad T440s, bought second-hand in 2018.
# It is named after the song "Saelli" by "Corpo-Mente".

let
  cascade = import ../cascade.nix;
  network = import ../../network.nix;

in { config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/efi.nix
    ../extras/desktop
    ../extras/audio.nix
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

  environment.systemPackages = with pkgs; [
    steam
    (writeShellScriptBin "eduroam" ''
      set -o errexit -o nounset
      sudo ${gnused}/bin/sed -i -E '/${lib.concatStringsSep "|" config.networking.nameservers}/d' /etc/resolv.conf
    '')
  ];

  hardware.firmware = with pkgs; [ firmwareLinuxNonfree ];  # wifi driver

  networking.wireguard = {
    enable = true;
    interfaces.wg-k8s = let
      localAddr = network.byName."k8s.saelli.cascade".address;
      prefixLength = network.byName."k8s.network.cascade".prefixLength;
    in {
      ips = [ "${localAddr}/${builtins.toString prefixLength}" ];
      privateKey = (import ../../secret/passwords.nix).k8s-vpn.saelli;
      peers = [
        (let
          remoteAddr = network.byName."k8s.beagle2.cascade".address;
          endpointAddr = network.byName."pub4.beagle2.cascade".address;
          endpointPort = 14137;
        in {
          endpoint = "${endpointAddr}:${builtins.toString endpointPort}";
          publicKey = "mYnDERLKGuwmWSS6PkAdTuBnjnqr+hzg9n0VlnLJd3Q=";
          allowedIPs = [
            "${remoteAddr}/32"
            "10.96.0.0/12"  # k8s services
          ];
          persistentKeepalive = 25;
        })
      ];
    };
  };
  networking.nameservers = lib.mkForce ([
    "10.96.0.10"  # kube-dns.kube-system.svc.cluster.local
  ] ++ network.upstreamNameservers);
}
