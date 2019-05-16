{ clientCert, clientKey, runCommand, ipv6-internet }:

let
  template = ./config.template;
  campanella2-iface = if ipv6-internet then "public6" else "public4";
  campanella2-addr = (import ../../cascade.nix).addrs."${campanella2-iface}.campanella2.h.cascade";
  config = runCommand "client.conf" {
    inherit clientCert clientKey;
    remoteHost = campanella2-addr;
    remotePort = 1194;
    caCert     = ../../../secret/vpn/certs/ca.crt;
    vpnHmacKey = ../../../secret/vpn/ta.key;
  } "substituteAll ${template} $out";

in config
