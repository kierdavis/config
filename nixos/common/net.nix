{ config, pkgs, lib, ... }:

let
  hist = import ../../hist.nix;
  passwords = import ../../secret/passwords.nix;
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
    interfaces.wg-hist = let
      localAddr = hist.hosts."${config.machine.name}".addresses.wg;
      prefixLength = hist.networks.wg.prefixLength;
    in {
      ips = ["${localAddr}/${builtins.toString prefixLength}"];
      listenPort = hist.wgPort;
      privateKeyFile = "/etc/wg-hist.key";
      peers = lib.mapAttrsToList (peerName: peer: {
        inherit (peer) publicKey;
        allowedIPs = ["${peer.addresses.wg}/128"] ++ (peer.wgGatewayTo or []);
        endpoint = if peer ? addresses.default.public then "${peer.addresses.default.public}:${builtins.toString hist.wgPort}" else null;
        persistentKeepalive = 25;
      }) (lib.filterAttrs (peerName: peerInfo: peerName != config.machine.name && peerInfo ? addresses.wg) hist.hosts);
    };
  };
  networking.firewall.allowedUDPPorts = [ hist.wgPort ];

  networking.hosts = lib.groupBy' (names: entry: names ++ [entry.name]) [] (entry: entry.address) hist.dns;
}
