{ config, lib, pkgs, ... }:

with lib;

let
  modConfig = config.campanella-vpn.client;

  vpnConfig = import ./config.nix {
    inherit (pkgs) runCommand;
    clientCert = modConfig.certFile;
    clientKey = modConfig.keyFile;
  };

in {
  options.campanella-vpn.client = {
    enable = mkEnableOption "Campanella VPN client";

    certFile = mkOption {
      type = types.path;
      description = "Path to a file containing the client's certificate.";
    };

    keyFile = mkOption {
      type = types.path;
      description = "Path to a file containing the client's private key.";
    };
  };

  config.services.openvpn.servers.campanella-client = mkIf modConfig.enable {
    config = "config '${vpnConfig}'";
    autoStart = true;
  };
}
