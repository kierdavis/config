let
  nordvpn-client = { config, lib, pkgs, ... }:
    let
      nordvpn = import ../../secret/nordvpn { inherit pkgs; };
      campanella2 = (import ../hosts.nix { inherit pkgs; }).hosts.campanella2;
    in {
      services.openvpn.servers.nordvpn = {
        config = nordvpn.config;
        autoStart = true;
      };
      environment.etc."resolvconf.conf".text = ''
        # NordVPN name servers
        name_servers="103.86.96.100 103.86.99.100"
      '';
      networking.interfaces.eth0.ipv4.routes = [
        { address = campanella2; prefixLength = 32; via = "192.168.1.1"; }
        { address = nordvpn.host; prefixLength = 32; via = "192.168.1.1"; }
      ];
      networking.firewall.extraCommands = ''
        # Reset the OUTPUT chain (delete all rules)
        iptables -F OUTPUT
        iptables -P OUTPUT ACCEPT
        # Allow traffic to VPN entry points
        iptables -A OUTPUT --destination ${campanella2} -j ACCEPT
        iptables -A OUTPUT --destination ${nordvpn.host} -j ACCEPT
        # Allow traffic to LAN
        iptables -A OUTPUT --destination 192.168.1.0/24 -j ACCEPT
        # Disallow all other traffic through eth0.
        iptables -A OUTPUT --out-interface eth0 -j REJECT
      '';
    };

  torrent-client = { config, lib, pkgs, ... }: {
    services.transmission = {
      enable = true;
      port = 9091; # web interface
      home = "/srv/transmission";
      settings = import ../transmission-settings.nix // {
        download-dir = "/downloads";
      };
    };
    networking.firewall.allowedTCPPorts = [ 9091 ];
    systemd.services.transmission.after = [ "openvpn-nordvpn.service" ];
    systemd.services.transmission.requires = [ "openvpn-nordvpn.service" ];
  };

  nfs-server = { config, lib, pkgs, ... }: {
    services.nfs.server = {
      enable = true;
      exports = ''
        /downloads 10.99.0.0/16(ro,all_squash,anonuid=70,anongid=70)
      '';
    };
    networking.firewall.allowedTCPPorts = [ 2049 ];
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/proxmox-ct.nix
    ../extras/headless.nix
    nordvpn-client
    torrent-client
    nfs-server
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "cherry";
    wifi = false;
    cpu = {
      cores = 32;
      intel = true;
    };
  };

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "2689139e";

  # VPN client config.
  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/cherry.crt;
    keyFile = "/etc/cherry.key";
  };
}
