{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib;

  hosts = import ../../vpn-hosts.nix;

  clientConfigScriptSegment = name: addr: ''echo "ifconfig-push ${addr} 255.255.0.0" > $out/${name}'';
  clientConfigScript = lib.concatStringsSep "\n" (lib.mapAttrsToList clientConfigScriptSegment hosts);
  clientConfigDir = pkgs.runCommand "client-config" {} ''
    #!${pkgs.stdenv.shell}
    mkdir -p $out
    ${clientConfigScript}
  '';

  serverConfTemplate = ./vpnserver.conf;
  serverConf = pkgs.runCommand "server.conf" {
    caCert     = ../../../secret/pki/ca.crt;
    serverCert = ../../../secret/pki/campanella-vpnserver.crt;
    serverKey  = ../../../secret/pki/campanella-vpnserver.key;
    dhParams   = ../../../secret/pki/dh.pem;
    vpnHmacKey = ../../../secret/vpn-hmac.key;
    inherit clientConfigDir;
  } "substituteAll ${serverConfTemplate} $out";

  runScript = pkgs.writeScript "campanella-vpnserver-run" ''
    #!${pkgs.stdenv.shell}
    set -o errexit -o pipefail -o nounset

    # Start the OpenVPN server.
    ${pkgs.openvpn}/bin/openvpn --config ${serverConf}
  '';

  image = pkgs.dockerTools.buildImage {
    name = "campanella-vpnserver";
    tag = "latest";
    fromImage = pkgs.dockerTools.pullImage {
      imageName = "busybox";
      imageTag = "1.27.2";
      sha256 = "1w53ia9hdry6im4pcdqmjqsp5zawgjfdp5f5x7kvqivcpbpjbw99";
    };
    contents = pkgs.runCommand "campanella-vpnserver-contents" {} ''
      mkdir -p $out/tmp
    '';
    config = {
      Cmd = [ runScript ];
      ExposedPorts = {
        "1194/udp" = {};
      };
    };
  };

in image
