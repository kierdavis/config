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
in

{
  # redshift (adjusts colour temperature of displays at night)
  services.redshift.enable = true;

  # Backlight control
  programs.light.enable = true;

  # Other programs
  programs.adb.enable = false;
  programs.chromium.enable = true;
  programs.steam.enable = true;
  virtualisation.virtualbox.host.enable = true;
  environment.systemPackages = with pkgs; [
    citrix_workspace
    dmenu
    evince
    gimp
    gnome3.eog
    google-chrome
    i3blocks
    i3blocks-scripts
    i3lock
    mailboxes
    multimc
    openttd_1_10_2
    pavucontrol
    pinentry-gnome
    screenshot
    signal-desktop
    spotify
    terminator
    vlc
    zoom-us

    # Development
    geda
    pcb
    quartus
    freecad
    repetier-host
    slic3r-prusa3d
  ];
}
