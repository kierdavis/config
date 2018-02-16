{ config, lib, pkgs, ... }:

let
  localPkgs = import ../../../pkgs pkgs;

in {
  # VirtualBox
  virtualisation.virtualbox.host.enable = true;

  # redshift (adjusts colour temperature of displays at night)
  services.redshift = {
    enable = true;
    latitude = "50.92";
    longitude = "-1.39";
  };

  # Backlight control
  programs.light.enable = true;

  environment.systemPackages = with localPkgs; [
    chromium
    dmenu
    evince
    gimp
    gnome3.eog
    i3blocks
    i3blocks-scripts
    i3lock
    networkmanagerapplet
    pavucontrol
    quasselClient
    screenshot
    soton-rdp
#    spotify
    sublime3
    terminator
    vlc
  ];
}
