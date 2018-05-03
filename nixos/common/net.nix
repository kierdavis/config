{ config, pkgs, lib, ... }:

{
  imports = [
    ../vpn
  ];

  networking.hostName = config.machine.name;

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

  # /etc/hosts
  networking.extraHosts = (import ../hosts.nix { inherit pkgs; }).fileContents;
}
