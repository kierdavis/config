{ clientCert, clientKey, runCommand }:

let
  template = ./config.template;
  config = runCommand "client.conf" {
    inherit clientCert clientKey;
    remoteHost = "campanella2";
    remotePort = 1194;
    caCert     = ../../../secret/vpn/certs/ca.crt;
    vpnHmacKey = ../../../secret/vpn/ta.key;
  } "substituteAll ${template} $out";

in config
