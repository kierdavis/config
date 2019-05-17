{ config, pkgs, lib, ... }:

{
  imports = [
    ../vpn
  ];

  networking.hostName = config.machine.name;

  networking.nameservers = let
    cascade = import ../cascade.nix;
    campanella2-iface = if config.machine.ipv6-internet then "public6" else "public4";
    campanella2-addr = cascade.addrs."${campanella2-iface}.campanella2.h.cascade";
  in [ campanella2-addr ] ++ cascade.upstreamNameservers;

  # Firewall
  networking.firewall.enable = true;
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
}
