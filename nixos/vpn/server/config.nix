{ lib, runCommand, serverCert, serverKey, stdenv }:

let
  hosts = import ../hosts.nix;

  clientConfigScriptSegment = name: addr: ''echo "ifconfig-push ${addr} 255.255.0.0" > $out/${name}'';
  clientConfigScript = lib.concatStringsSep "\n" (lib.mapAttrsToList clientConfigScriptSegment hosts);
  clientConfigDir = runCommand "client-config" {} ''
    #!${stdenv.shell}
    mkdir -p $out
    ${clientConfigScript}
  '';

  template = ./config.template;
  config = runCommand "vpnserver.conf" {
    inherit clientConfigDir serverCert serverKey;
    caCert     = ../../../secret/pki/ca.crt;
    dhParams   = ../../../secret/pki/dh.pem;
    vpnHmacKey = ../../../secret/vpn-hmac.key;
  } "substituteAll ${template} $out";

in config
