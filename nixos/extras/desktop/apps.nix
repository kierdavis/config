{ config, lib, pkgs, ... }:

let
  chromium-river = pkgs.writeShellScriptBin "chromium-river" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.chromium}/bin/chromium --user-data-dir=$HOME/.river/chromium "$@"
  '';

  pkgs-latest = import (fetchTarball https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz) {
    inherit (config.nixpkgs) config;
  };
  skype-latest = pkgs-latest.skype;
in

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
    chromium-river
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
    soton-rdp
    spotify
    sublime3
    terminator
    tor-browser-bundle
    vlc
  ];
}
