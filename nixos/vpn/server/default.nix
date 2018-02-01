{ config, lib, pkgs, ... }:

with lib;

let
  modConfig = config.campanella-vpn.server;

  vpnConfig = import ./config.nix {
    inherit lib;
    inherit (pkgs) runCommand stdenv;
    serverCert = modConfig.certFile;
    serverKey = modConfig.keyFile;
  };

in {
  options.campanella-vpn.server = {
    enable = mkEnableOption "Campanella VPN server";

    certFile = mkOption {
      type = types.path;
      description = "Path to a file containing the server's certificate.";
    };

    keyFile = mkOption {
      type = types.path;
      description = "Path to a file containing the server's private key.";
    };
  };

  config.services.openvpn.servers.campanella-server = mkIf modConfig.enable {
    config = "config '${vpnConfig}'";
    autoStart = true;
  };
}
