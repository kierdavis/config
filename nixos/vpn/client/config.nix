{ clientCert, clientKey, runCommand, ipv6-internet }:

let
  template = ./config.template;
  cascade = import ../../cascade.nix;
  pubSeg = if config.machine.ipv6-internet then cascade.addrs.pub else cascade.addrs.pub4;
  config = runCommand "client.conf" {
    inherit clientCert clientKey;
    remoteHost = pubSeg.campanella2;
    remotePort = 1194;
    caCert     = ../../../secret/vpn/certs/ca.crt;
    vpnHmacKey = ../../../secret/vpn/ta.key;
  } "substituteAll ${template} $out";

in config
