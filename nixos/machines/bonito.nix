let
  print-server = { config, lib, pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = [ pkgs.samsung-unified-linux-driver_4_01_17 ];
    };
    networking.firewall.allowedTCPPorts = [ 631 ];
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/proxmox-ct.nix
    ../extras/headless.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "bonito";
    wifi = false;
    cpu = {
      cores = 4;
      intel = true;
    };
  };

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "00e60dbb";

  # VPN client config.
  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/bonito.crt;
    keyFile = "/etc/bonito.key";
  };
}
