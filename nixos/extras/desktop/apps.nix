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
    ecs-rdp
    ecs-rdp-tunnel
    evince
    gimp
    gnome3.eog
    i3blocks
    i3blocks-scripts
    ledger
    lock
    multimc
    networkmanagerapplet
    pavucontrol
    python27Packages.youtube-dl
    quasselClient
    screenshot
    skype
    steam
    sublime3
    terminator
    vlc
  ];

  environment.variables.LEDGER_FILE = "/mnt/nocturn/documents/accounts/top.journal";
}
