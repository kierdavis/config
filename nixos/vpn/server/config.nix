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
    caCert     = ../../../secret/vpn/certs/ca.crt;
    dhParams   = ../../../secret/vpn/dh.pem;
    vpnHmacKey = ../../../secret/vpn/ta.key;
  } "substituteAll ${template} $out";

in config
