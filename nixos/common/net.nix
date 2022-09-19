{ config, pkgs, lib, ... }:

let
  hist = import ../../hist.nix;
  hist3 = import ../../hist3.nix;
  passwords = import ../../secret/passwords.nix;

  hist5 =
    let
      secretCueDir = ../../secret/hist5/cue;
      jsonFile = pkgs.runCommand "hist5-cue.json" {} ''
        cp -rs ${../../hist5/cue} cue
        chmod -R +w cue
        ln -sfT ${../../secret/hist5/cue/secrets.cue} cue/secrets.cue
        cd cue
        ${pkgs.cue}/bin/cue export --out=json > $out
      '';
    in builtins.fromJSON (builtins.readFile jsonFile);

in

{
  networking.hostName = config.machine.name;
  networking.domain = "hist";

  networking.iproute2.enable = true;

  # Firewall
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowPing = true;

  # Debugging:
  networking.firewall.logReversePathDrops = true;

  # Allow the 'gre' (Generic Routing Encapsulation) IP protocol.
  # The Windows PPTP VPN client uses this; if it is run in a VM, its traffic will still need to go through this firewall.
  #networking.firewall.extraCommands = "ip46tables -A nixos-fw -p gre -j nixos-fw-accept";

  # Bluetooth
  # bluetoothctl doesn't seem to work properly on any of my machines...
  hardware.bluetooth.enable = false;

  # When forwarding a port from a host to a container using systemd-nspawn, this setting is
  # required in order to make the port accessible from other machine's on the host's network.
  # https://docs.docker.com/v17.09/engine/userguide/networking/default_network/container-communication/#communicating-to-the-outside-world
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

  # Local DNS server.
  #services.unbound = {
  #  enable = true;
  #  interfaces = [ "127.0.0.1" "::1" ];
  #  allowedAccess = [ "127.0.0.1/32" "::1/128" ];
  #  forwardAddresses = network.upstreamNameservers;
  #  extraConfig = let
  #    serialiseRecord = record: if record.type == "A" || record.type == "AAAA"
  #      then ''local-data: "${record.name}. IN ${record.type} ${record.address}"''
  #      else if record.type == "CNAME"
  #        then ''local-sata: "${record.name}. IN CNAME ${record.targetName}"''
  #        else "";
  #  in ''
  #    local-zone: "cascade." static
  #    ${lib.concatStringsSep "\n" (map serialiseRecord network.records)}
  #  '';
  #};
  #networking.nameservers = [ "::1" ];

  networking.wireguard = {
    enable = true;
    interfaces.wg-hist5 = {
      ips = ["${hist5.machines."${config.networking.hostName}".addresses.wireguard}/${builtins.toString hist5.networks.wireguard.prefixLength}"];
      listenPort = hist5.networks.wireguard.listenPort;
      privateKey = hist5.machines."${config.networking.hostName}".wireguardKey.private;
      peers = builtins.map (peer: {
        allowedIPs = [
          "${peer.addresses.wireguard}/32"
        ] ++ lib.optionals (peer.name == "talosgcp1") [
          hist5.networks.services.cidr
          hist5.networks.pods.cidr
        ];
        endpoint = "${peer.addresses.internet}:${builtins.toString hist5.networks.wireguard.listenPort}";
        publicKey = peer.wireguardKey.public;
        persistentKeepalive = 25;
      }) (builtins.filter (peer: peer.name != config.networking.hostName) (lib.attrsets.attrValues hist5.machines));
      postSetup = ''
        ip link set dev wg-hist5 mtu ${builtins.toString hist5.networks.wireguard.mtu}
      '';
      # postSetup = ''
      #   ${pkgs.openresolv}/bin/resolvconf -a wg-hist5 -m 10 <<EOF
      #   nameserver 10.171.8.10
      #   EOF
      # '';
      # postShutdown = ''
      #   ${pkgs.openresolv}/bin/resolvconf -d wg-hist5
      # '';
    };
  };

  networking.hosts = lib.groupBy' (names: entry: names ++ [entry.name]) [] (entry: entry.address) hist.dns;

  networking.interfaces.lo.ipv4.addresses = [{
    address = hist3.nodes."${config.networking.hostName}".addresses.hist3_v4;
    prefixLength = hist3.networks.hist3_v4.prefixLength;
  }];
}
