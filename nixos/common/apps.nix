{ config, lib, pkgs, ... }:

let
  localPkgs = import ../../pkgs pkgs;

  mkWake = name: mac: localPkgs.writeScriptBin "wake-${name}" ''
    #!${localPkgs.stdenv.shell}
    ${localPkgs.wakelan}/bin/wakelan ${mac}
  '';

in {
  # sudo
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # tmux
  programs.tmux.enable = true;

  # bash completion
  programs.bash.enableCompletion = true;

  # NixOS manual
  services.nixosManual.enable = true;

  environment.systemPackages = with localPkgs; [
    bc
    beets
    file
    git
    gnupg
    htop
    ledger
    manpages
    mountext
    nmap
    pass
    passchars
    pbzip2
    pigz
    publish
    pv
    python27Packages.youtube-dl
    soton-mount
    soton-umount
    umountext
    usbutils  # lsusb
    unzip
    wget
    zip

    (mkWake "coloris" "34:97:f6:34:19:3f")
    (mkWake "nocturn" "00:26:b9:bf:1f:52")
    (mkWake "htpc" "d4:3d:7e:ef:5c:e5")
  ];

  environment.variables = {
    PKGS = "/nix/var/nix/profiles/per-user/root/channels/nixos/pkgs/top-level/all-packages.nix";

    GPG_MASTER_KEY = "8139C5FCEDA73ABF";
    GPG_ENCRYPTION_KEY = "DFDCA524B0742D62";
    GPG_GIT_SIGNING_KEY = "66378DA35FF9F0FA";
  };
}
