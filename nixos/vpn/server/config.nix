{ lib, runCommand, serverCert, serverKey, stdenv }:

let
  hostnames = [ "coloris" "ouroboros" "bonito" "saelli" "cherry" ];
  cascade = import ../../cascade.nix;

  clientConfigScriptSegment = hostname:
    let addr = cascade.addrs.c2vpn."${hostname}";
    in ''echo "ifconfig-push ${addr} 255.255.0.0" > $out/${hostname}'';
  clientConfigScript = lib.concatStringsSep "\n" (map clientConfigScriptSegment hostnames);
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
