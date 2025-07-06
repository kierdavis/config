{ config, pkgs, lib, ... }:

{
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    # networks defined in config-secret#nixosModules.common
  };
  environment.systemPackages = [ pkgs.wpa_supplicant_gui ];
}
