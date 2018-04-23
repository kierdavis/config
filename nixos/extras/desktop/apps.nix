{ config, lib, pkgs, ... }:

{
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

  environment.systemPackages = with pkgs; [
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
    signal-desktop
    skype
    soton-rdp
    spotify
    sublime3
    terminator
    tor-browser-bundle
    vlc
  ];
}
