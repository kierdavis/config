{ config, lib, pkgs, ... }:

let
  mailboxes = let
    c = "${pkgs.chromium}/bin/chromium";
  in pkgs.writeShellScriptBin "mailboxes" ''
    ${c} https://mail.google.com/mail/u/0/ &
    ${c} https://mail.google.com/mail/u/1/ &
    ${c} https://mail.zoho.eu/zm/ &
    wait
  '';

  netflix = pkgs.writeShellScriptBin "netflix" ''
    exec ${pkgs.google-chrome}/bin/google-chrome-stable https://www.netflix.com/
  '';
in

{
  # redshift (adjusts colour temperature of displays at night)
  services.redshift.enable = true;

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
    netflix
    pavucontrol
    pinentry-gnome
    screenshot
    signal-desktop
    spotify
    terminator
    vlc
    zoom-us
  ];
}
