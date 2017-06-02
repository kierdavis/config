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
    gimp
    gnome3.eog
    i3blocks
    i3blocks-scripts
    i3lock
    lock
    networkmanagerapplet
    pavucontrol
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

  environment.variables.LEDGER_FILE = "/mnt/nocturn/documents/accounts/top.journal";
}
