{ config, pkgs, lib, ... }:

let
  hist = import ../../hist.nix;
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
        publicKey = peer.wireguardKey.public;
        persistentKeepalive = 25;
      } // lib.optionalAttrs (peer.addresses.internet != null) {
        endpoint = "${peer.addresses.internet}:${builtins.toString hist5.networks.wireguard.listenPort}";
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

  # resolvconf prioritises interfaces according to a metric (lower is better).
  # This metric is provided via -m or IFMETRIC when resolvconf -a is called.
  # NixOS static configuration (networking.nameservers) option has metric 1.
  # DHCP interfaces have a default metric of 1000 + if_nametoindex(3), but this can be overridden in dhcpcd.conf.
  networking.resolvconf.enable = true;
  systemd.services.fallback-dns-config = {
    inherit (config.systemd.services.network-setup) before wants partOf conflicts wantedBy;
    after = ["network-pre.target"];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    unitConfig.DefaultDependencies = false;
    script = ''
      ${pkgs.openresolv}/sbin/resolvconf -a static-fallback -m 800 <<EOF
      nameserver 1.1.1.1
      nameserver 1.0.0.1
      EOF
    '';
    preStop = ''
      ${pkgs.openresolv}/sbin/resolvconf -d static-fallback
    '';
  };
}
