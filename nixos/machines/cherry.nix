let
  cascade = import ../cascade.nix;

  nordvpn-client = { config, lib, pkgs, ... }:
    let
      nordvpn = import ../../secret/nordvpn { inherit pkgs; };
      campanella2 = (import ../cascade.nix).addrs.pub4.campanella2;
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
    users.users.kier.extraGroups = [ "transmission" ];
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

    systemd.services.sync-torrent-files = {
      description = "Sync torrent files from transmission data directory to archive directory";
      script = ''
        dest=/srv/transmission/torrent-archive
        ${pkgs.rsync}/bin/rsync -av /srv/transmission/.config/transmission-daemon/torrents/ $dest/
        chmod 0755 $dest
        chmod 0644 $dest/*.torrent
      '';
      serviceConfig = {
        PermissionsStartOnly = true;
        User = "transmission";
      };
      startAt = "daily";
    };
  };

  nfs-server = { config, lib, pkgs, ... }: {
    services.nfs.server = {
      enable = true;
      exports = ''
        /downloads 10.99.0.0/16(ro,all_squash,anonuid=70,anongid=70)
        /srv/transmission/torrent-archive 10.99.0.0/16(ro,all_squash,anonuid=70,anongid=70)
      '';
    };
    networking.firewall.allowedTCPPorts = [ 2049 ];
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/proxmox-ct.nix
    ../extras/headless.nix
    #nordvpn-client
    #torrent-client
    nfs-server
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "cherry";
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
  networking.hostId = "2689139e";

  networking.useDHCP = false;
  networking.interfaces.eth0 = {
    useDHCP = false;
    ipv4.addresses = [ { address = cascade.addrs.cl4.cherry; prefixLength = 24; } ];
    ipv6.addresses = [ { address = cascade.addrs.cl.cherry; prefixLength = 112; } ];
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
