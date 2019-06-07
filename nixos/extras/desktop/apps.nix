{ config, lib, pkgs, ... }:

let
  mailboxes = let
    c = "${pkgs.chromium}/bin/chromium";
  in pkgs.writeShellScriptBin "mailboxes" ''
    ${c} https://mail.google.com/ &
    ${c} http://ecs.gg/mail &
    ${c} https://mail.zoho.eu/zm/ &
    wait
  '';
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

  # Other programs
  programs.chromium.enable = true;
  environment.systemPackages = with pkgs; [
    chromium
    dmenu
    evince
    gimp
    gnome3.eog
    i3blocks
    i3blocks-scripts
    i3lock
    mailboxes
    multimc
    pavucontrol
    screenshot
    signal-desktop
    spotify
    sublime3
    terminator
    tor-browser-bundle
    vlc
  ];
}
