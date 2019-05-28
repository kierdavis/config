let
  cascade = import ../cascade.nix;

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/proxmox-ct.nix
    ../extras/headless.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "moon";
    wifi = false;
    ipv6-internet = false;
    cpu = {
      cores = 24;
      intel = true;
    };
  };

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "3018b47b";

  networking.useDHCP = false;
  networking.interfaces.eth0 = {
    useDHCP = false;
    ipv4.addresses = [ { address = cascade.addrs.cl4.moon; prefixLength = 24; } ];
    ipv6.addresses = [ { address = cascade.addrs.cl.moon; prefixLength = 112; } ];
  };
  networking.defaultGateway = {
    address = cascade.addrs.cl4.altusanima;
    interface = "eth0";
  };
  networking.defaultGateway6 = {
    address = cascade.addrs.cl.altusanima;
    interface = "eth0";
  };
}
