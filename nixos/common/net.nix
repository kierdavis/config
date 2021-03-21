{ config, pkgs, lib, ... }:

let
  network = import ../../network.nix;
  passwords = import ../../secret/passwords.nix;
in

{
  networking.hostName = config.machine.name;

  # Firewall
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPortRanges = [
    { from = 8080; to = 8090; }
  ];

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

  networking.nameservers = ["10.96.1.0" "208.67.222.222" "208.67.220.220"];
  networking.networkmanager.dns = "none";

  networking.wireguard = {
    enable = true;
    interfaces.wg-k8s = let
      localAddr = network.byName."k8s.${config.machine.name}.cascade".address;
      prefixLength = network.byName."k8s.network.cascade".prefixLength;
    in {
      ips = [ "${localAddr}/${builtins.toString prefixLength}" ];
      privateKey = passwords.k8s-vpn."${config.machine.name}".private;
      peers = [
        (let
          endpointAddr = network.byName."pub4.beagle2.cascade".address;
          endpointPort = 14137;
        in {
          endpoint = "${endpointAddr}:${builtins.toString endpointPort}";
          publicKey = passwords.k8s-vpn.beagle2.public;
          allowedIPs = [
            network.byName."k8s.network.cascade".cidr
            "10.32.0.0/12"  # k8s pods
            "10.96.0.0/12"  # k8s services
          ];
          persistentKeepalive = 25;
        })
      ];
    };
  };
}
