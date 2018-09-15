{ config, lib, pkgs, ... }:

let
  mkWake = name: mac: pkgs.writeShellScriptBin "wake-${name}" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.wakelan}/bin/wakelan ${mac}
  '';

in {
  # sudo
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # tmux
  programs.tmux.enable = true;

  # bash completion
  programs.bash.enableCompletion = true;

  # NixOS manual
  services.nixosManual.enable = true;

  environment.systemPackages = with pkgs; [
    # Utilities
    bc
    duplicity
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
    screen
    soton-mount
    soton-umount
    sshfs
    umountext
    unzip
    wget
    zip
    (mkWake "coloris" "34:97:f6:34:19:3f")
    (mkWake "htpc" "d4:3d:7e:ef:5c:e5")

    # System diagnostics
    htop
    lsof
    nmap
    pciutils  # lspci
    usbutils  # lsusb

    # Security
    gnupg
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
