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
    # Utilities
    bc
    file
    git
    manpages
    mountext
    nix-repl
    pbzip2
    pigz
    publish
    pv
    soton-mount
    soton-umount
    umountext
    unzip
    wget
    zip
    (mkWake "coloris" "34:97:f6:34:19:3f")
    (mkWake "nocturn" "00:26:b9:bf:1f:52")
    (mkWake "htpc" "d4:3d:7e:ef:5c:e5")

    # System diagnostics
    htop
    nmap
    pciutils  # lspci
    usbutils  # lsusb

    # Security
    gnupg
    keybase
    pass
    passchars

    # Other (probably don't need to be in base build)
    beets
    python27Packages.youtube-dl
  ];

  environment.variables = {
    PKGS = "/nix/var/nix/profiles/per-user/root/channels/nixos/pkgs/top-level/all-packages.nix";

    GPG_MASTER_KEY = "8139C5FCEDA73ABF";
    GPG_ENCRYPTION_KEY = "DFDCA524B0742D62";
    GPG_GIT_SIGNING_KEY = "66378DA35FF9F0FA";

    TMUX_TMPDIR = lib.mkForce "/tmp";
  };
}
