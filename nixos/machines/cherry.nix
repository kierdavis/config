let
#  nordvpn-client = { config, lib, pkgs, ... }: {
#    services.openvpn.servers.nordvpn = {
#      config = nordvpn.config;
#      autoStart = true;
#    };
#    environment.etc."resolv.conf".text = ''
#      # NordVPN name servers
#      nameserver 103.86.96.100
#      nameserver 103.86.99.100
#    '';
#    networking.firewall.extraCommands = ''
#      # Reset the OUTPUT chain (delete all rules)
#      iptables -F OUTPUT
#      iptables -P OUTPUT ACCEPT
#      # Allow traffic to NordVPN's entry point
#      iptables -A OUTPUT --protocol tcp --destination ${nordvpn.host} --dport ${toString nordvpn.port} -j ACCEPT
#      # Disallow all other traffic through eth0.
#      iptables -A OUTPUT --out-interface eth0 -j REJECT
#    '';
#  };
#
#  torrent-client = { config, lib, pkgs, ... }: {
#    services.openvpn.servers.nordvpn = {
#      config = nordvpn.config;
#      autoStart = true;
#    };
#  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/proxmox-ct.nix
    ../extras/headless.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "cherry";
    wifi = false;
    cpu = {
      cores = 4;
      intel = true;
    };
  };

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "2689139e";

  # VPN client config.
  #campanella-vpn.client = {
  #  enable = true;
  #  certFile = ../../secret/vpn/certs/cherry.crt;
  #  keyFile = "/etc/cherry.key";
  #};
}
