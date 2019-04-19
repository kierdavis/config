{ config, lib, pkgs, ... }:

let
  mkWake = name: mac: pkgs.writeShellScriptBin "wake-${name}" ''
    ${pkgs.wakelan}/bin/wakelan ${mac}
  '';

in {
  # sudo
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # bash completion
  programs.bash.enableCompletion = true;

  # documentation
  documentation = {
    enable = true;
    nixos.enable = true;
    dev.enable = false;

    # Types of documentation
    man.enable = true;
    info.enable = true;
    doc.enable = false; # anything that doesn't fall into the above two categories
  };

  # other programs
  programs.less.enable = true;
  programs.tmux.enable = true;
  environment.systemPackages = with pkgs; [
    # Utilities
    bc
    duplicity
    file
    git
    manpages
    mountext
    pbzip2
    pigz
    psmisc  # provides killall
    publish
    pv
    screen
    sshfs
    umountext
    unzip
    wget
    zip
    (mkWake "altusanima" "b8:ac:6f:99:63:c4")
    (mkWake "coloris" "34:97:f6:34:19:3f")
    (mkWake "shadowshow" "d8:9d:67:64:86:cf")

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
