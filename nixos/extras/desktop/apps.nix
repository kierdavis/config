{ config, lib, pkgs, ... }:

let
  chromium-river = pkgs.writeShellScriptBin "chromium-river" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.chromium}/bin/chromium --user-data-dir=$HOME/.river/chromium "$@"
  '';

  mailboxes = let
    c = "${pkgs.chromium}/bin/chromium";
    cr = "${chromium-river}/bin/chromium-river";
  in pkgs.writeShellScriptBin "mailboxes" ''
    ${c} https://mail.google.com/ &
    ${c} http://ecs.gg/mail &
    ${c} https://mail.zoho.eu/zm/ &
    ${cr} https://mail.google.com/ &
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
    chromium-river
    dmenu
    evince
    gimp
    gnome3.eog
    i3blocks
    i3blocks-scripts
    i3lock
    mailboxes
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
