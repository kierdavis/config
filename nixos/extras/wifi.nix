{ config, pkgs, lib, ... }:

{
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = import ../../secret/wifi-networks.nix;
  };
  environment.systemPackages = [ pkgs.wpa_supplicant_gui ];
}
