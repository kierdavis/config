{ config, lib, pkgs, ... }:

let
  localPkgs = import ../../../pkgs pkgs;

in {
  # VirtualBox
  virtualisation.virtualbox.host.enable = config.machine.vboxHost;

  environment.systemPackages = with localPkgs; [
    beets
    chromium
    dmenu
    ecs-rdp-roo
    evince
    geda
    gimp
    gnome3.eog
    i3blocks
    i3blocks-scripts
    i3lock
    lock
    logisim
    networkmanagerapplet
    pavucontrol
    pcb
    pysolfc
    python27Packages.youtube-dl
    quasselClient
    screenshot
    skype
    spotify
    steam
    sublime3
    terminator
    vlc
  ];
}
