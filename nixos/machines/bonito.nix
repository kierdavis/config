let
  print-server = { config, lib, pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = [ pkgs.samsung-unified-linux-driver_4_01_17 ];
    };
    networking.firewall.allowedTCPPorts = [ 631 ];
    environment.variables.CUPS_SERVER = lib.mkForce ""; # override common/print.nix
  };

  http-server = { config, lib, pkgs, ... }: {
    services.nginx = {
      enable = true;
      virtualHosts = {
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };

  mysql-server = { config, lib, pkgs, ... }: {
    services.mysql = {
      enable = true;
      dataDir = "/srv/mysql";
      package = pkgs.mysql;
      bind = "10.99.1.3";
      port = 3306;
    };
    networking.firewall.allowedTCPPorts = [ 3306 ];
  };

  wiki-server = { config, lib, pkgs, ... }: {
    services.gollum = {
      enable = true;
      address = "10.99.1.3";
      stateDir = "/srv/gollum";
    };
    networking.firewall.allowedTCPPorts = [ 4567 ];
    systemd.services.gollum.after = [ "openvpn-campanella-client.service" ];
    systemd.services.gollum.requires = [ "openvpn-campanella-client.service" ];
  };

  music-server = { config, lib, pkgs, ... }: {
    imports = [ ../lib/mstream.nix ];
    services.mstream = {
      enable = true;
      musicDir = "/data/music/library";
      dataDir = "/srv/mstream";
      lastfm = {
        username = "kierdavis";
        password = (import ../../secret/passwords.nix).lastfm;
      };
    };
    networking.firewall.allowedTCPPorts = [ 3000 ];
    environment.systemPackages = with pkgs; [ beets ];
  };

  cascade = import ../cascade.nix;

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/proxmox-ct.nix
    ../extras/headless.nix
    ../extras/netfs/cherry.nix
    print-server
    http-server
    mysql-server
    wiki-server
    music-server
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "bonito";
    wifi = false;
    cpu = {
      cores = 32;
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

  # cascade network
  networking.vlans.eth0_vlan11 = { interface = "eth0"; id = 11; };
  networking.interfaces.eth0_vlan11.ipv6 = {
    addresses = [ { address = cascade.hosts.bonito.addrs.vlan; prefixLength = 112; } ];
    routes = [ { address = cascade.addr; prefixLength = 96; via = cascade.hosts.altusanima.addrs.vlan; } ];
  };
  networking.nameservers = [ cascade.hosts.altusanima.addrs.vlan ];
}
