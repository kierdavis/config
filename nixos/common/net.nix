{ config, pkgs, lib, ... }:

{
  networking.hostName = config.machine.name;
  networking.domain = "hist5";

  networking.iproute2.enable = true;

  # Firewall
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowPing = true;

  # Debugging:
  networking.firewall.logReversePathDrops = true;

  # Bluetooth
  # bluetoothctl doesn't seem to work properly on any of my machines...
  hardware.bluetooth.enable = false;

  # When forwarding a port from a host to a container using systemd-nspawn, this setting is
  # required in order to make the port accessible from other machine's on the host's network.
  # https://docs.docker.com/v17.09/engine/userguide/networking/default_network/container-communication/#communicating-to-the-outside-world
  # TODO: can probably be removed once fingerbib is killed off.
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

  networking.wireguard = {
    enable = true;
    interfaces.wg-hist5 = {
      ips = ["${config.hist5.machines."${config.networking.hostName}".addresses.wireguard}/${builtins.toString config.hist5.networks.wireguard.prefixLength}"];
      listenPort = config.hist5.networks.wireguard.listenPort;
      privateKey = config.hist5.machines."${config.networking.hostName}".wireguardKey.private;
      peers = builtins.map (peer: {
        allowedIPs = [
          "${peer.addresses.wireguard}/32"
        ] ++ lib.optionals (peer.name == "talosgcp1") [
          config.hist5.networks.services.cidr
          config.hist5.networks.pods.cidr
        ];
        publicKey = peer.wireguardKey.public;
        persistentKeepalive = 25;
      } // lib.optionalAttrs (peer.addresses.internet != null) {
        endpoint = "${peer.addresses.internet}:${builtins.toString config.hist5.networks.wireguard.listenPort}";
      }) (builtins.filter (peer: peer.name != config.networking.hostName) (lib.attrsets.attrValues config.hist5.machines));
      postSetup = ''
        ip link set dev wg-hist5 mtu ${builtins.toString config.hist5.networks.wireguard.mtu}
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
