{ config, lib, pkgs, ... }:

let
  mkWake = name: mac: pkgs.writeScriptBin "wake-${name}" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.wakelan}/bin/wakelan ${mac}
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

  environment.systemPackages = with pkgs; [
    # Utilities
    bc
    file
    git
    manpages
    mountext
    nix-repl
    pbzip2
    pigz
    psmisc  # provides killall
    publish
    pv
    soton-mount
    soton-umount
    sshfs
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
  ];

  environment.variables = {
    PKGS = "/nix/var/nix/profiles/per-user/root/channels/nixos/pkgs/top-level/all-packages.nix";

    GPG_MASTER_KEY = "8139C5FCEDA73ABF";
    GPG_ENCRYPTION_KEY = "DFDCA524B0742D62";
    GPG_GIT_SIGNING_KEY = "66378DA35FF9F0FA";
    GPG_BACKUP_SIGNING_KEY = "EC1301FD757E43F7";

    TMUX_TMPDIR = lib.mkForce "/tmp";
  };
}
