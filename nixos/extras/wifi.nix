{ config, pkgs, lib, ... }:

let
  wifiSecrets = (import ../../secret/passwords.nix).wifi;
in {
  networking.wireless = {
    enable = true;
    networks = {
      "tubbyfrog24" = {
        psk = wifiSecrets.tubbyfrog;
      };
    };
  };
}
