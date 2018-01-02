{ config, pkgs, lib, ... }:

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
  networking.extraHosts = (import ../../hosts.nix { inherit pkgs; }).fileContents;

  # VPN
  services.openvpn.servers.campanella =
    let
      clientConfTemplate = ../../campanella/vpnclient.conf;
      clientConf = pkgs.runCommand "client.conf" {
        remoteHost = "beagle2";
        remotePort = 1194;
        caCert     = ../../secret/pki/ca.crt;
        clientCert = config.machine.vpn.clientCert;
        clientKey  = config.machine.vpn.clientKey;
        vpnHmacKey = ../../secret/vpn-hmac.key;
      } "substituteAll ${clientConfTemplate} $out";
    in
      {
        config = "config '${clientConf}'";
        autoStart = true;
      };
}
