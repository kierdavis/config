{ config, ... }:

{
  networking.hostName = config.machine.name;
  networking.hostId = config.machine.hostId;  # Necessary for ZFS. This is just a random 32-bit integer.

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # Allow the 'gre' (Generic Routing Encapsulation) IP protocol.
  # The Windows PPTP VPN client uses this; if it is run in a VM, its traffic will still need to go through this firewall.
  #networking.firewall.extraCommands = "ip46tables -A nixos-fw -p gre -j nixos-fw-accept";

  # Bluetooth
  hardware.bluetooth.enable = config.machine.bluetooth;

  # /etc/hosts
  networking.extraHosts = ''
    176.9.121.81 beagle2
    86.5.103.14 soton
  '';
}
