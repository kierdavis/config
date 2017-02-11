{ config, ... }:

{
  networking.hostName = config.machine.name;
  networking.hostId = config.machine.hostId;  # Necessary for ZFS. This is just a random 32-bit integer.

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [
    22    # SSH
  ];

  # Bluetooth
  hardware.bluetooth.enable = config.machine.bluetooth;

  # /etc/hosts
  networking.extraHosts = ''
    176.9.121.81 beagle2
  '';
}
