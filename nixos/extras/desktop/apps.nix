{ config, lib, pkgs, ... }:

let
  hostname = config.machine.name;

in {
  # redshift (adjusts colour temperature of displays at night)
  services.redshift.enable = true;

  # Backlight control
  programs.light.enable = true;

  # Other programs
  programs.chromium.enable = true;
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    audacity
    autorandr
    (blender.override { cudaSupport = config.machine.gpu.nvidia; })
    citrix_workspace
    cups  # client
    darktable
    dmenu
    evince
    freecad
    gimp
    gnome3.eog
    google-chrome
    i3blocks
    i3blocks-scripts
    i3lock
    pinentry-gnome3
    # polymc  # multimc successor
    prusa-slicer
    quartus
    # renoise
    screenshot
    spotify
    terminator
    tor-browser-bundle-bin
    vlc
    xfce.thunar
    zoom-us
  ];

  # For spotify to sync local files to other devices on the LAN via uPnP:
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 57621 ];
  };

  # Hack to make Google Chrome send DNS AAAA queries in addition to A queries even if the machine has no IPv6 internet connection.
  #networking.interfaces.lo.ipv6.routes = lib.optional (!config.machine.ipv6-internet) {
  #  address = "2001:4860:4860::8888";
  #  prefixLength = 128;
  #};
}
