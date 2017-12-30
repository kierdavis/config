{ pkgs ? import <nixpkgs> {} }:

let
  pkgs = import <nixpkgs> {};

  serverConfTemplate = ./vpnserver.conf;
  serverConf = pkgs.runCommand "server.conf" {
    caCert     = ../../../secret/pki/ca.crt;
    serverCert = ../../../secret/pki/campanella-vpnserver.crt;
    serverKey  = ../../../secret/pki/campanella-vpnserver.key;
    dhParams   = ../../../secret/pki/dh.pem;
    vpnHmacKey = ../../../secret/vpn-hmac.key;
    clientConfigDir = ./client-config;
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
