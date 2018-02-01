{ clientCert, clientKey, runCommand }:

let
  template = ./config.template;
  config = runCommand "client.conf" {
    inherit clientCert clientKey;
    remoteHost = "campanella2";
    remotePort = 1194;
    caCert     = ../../../secret/pki/ca.crt;
    vpnHmacKey = ../../../secret/vpn-hmac.key;
  } "substituteAll ${clientConfTemplate} $out";

in config
