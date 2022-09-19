{ config, lib, pkgs, ... }:

let
  hostname = config.machine.name;

in {
  # redshift (adjusts colour temperature of displays at night)
  services.redshift.enable = true;

  # Backlight control
  programs.light.enable = true;

  # Other programs
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    citrix_workspace
    cups  # client
    dmenu
    evince
    gimp
    gnome3.eog
    i3blocks
    i3blocks-scripts
    i3lock
    pavucontrol
    pinentry-gnome
    # polymc  # multimc successor
    screenshot
    spotify
    terminator
    tor-browser-bundle-bin
    vlc
    zoom-us

    # Development
    (blender.override { cudaSupport = config.machine.gpu.nvidia; })
    freecad
  ];

  # For spotify to sync local files to other devices on the LAN via uPnP:
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 57621 ];
  };

  environment.variables.CUPS_SERVER = "printing.hist:80";
  environment.variables.PRINTER = "HP_Envy_5640";
}
