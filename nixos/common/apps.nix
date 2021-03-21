{ config, lib, pkgs, ... }:

let
  nixos-rebuild-remote = pkgs.writeShellScriptBin "nixos-rebuild-remote" ''
    set -o errexit -o nounset -o pipefail
    host="$1"
    shift
    ping -c1 "$host"
    ssh_dir=/home/kier/.ssh
    ssh_key=$ssh_dir/$(ls $ssh_dir | grep -E '^id_(rsa|ed25519)$')
    exec nixos-rebuild --builders "ssh://nixremotebuild@$host - $ssh_key 4 - big-parallel" --max-jobs 0 "$@"
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
    nixos.enable = lib.mkDefault true;
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
    fzf
    git
    gptfdisk
    kakoune
    manpages
    mountext
    nixos-rebuild-remote
    pbzip2
    pigz
    psmisc  # provides killall
    publish
    pv
    ripgrep
    screen
    sshfs
    umountext
    unzip
    wget
    zip

    # System diagnostics
    dnsutils  # dig
    fping
    htop
    iotop
    lsof
    nmap
    pciutils  # lspci
    sysstat   # iostat
    usbutils  # lsusb

    # Security
    gnupg
    pass
    passchars
    pinentry-curses
  ];

  environment.variables = {
    GPG_MASTER_KEY = "8139C5FCEDA73ABF";
    GPG_ENCRYPTION_KEY = "DFDCA524B0742D62";
    GPG_GIT_SIGNING_KEY = "66378DA35FF9F0FA";
    GPG_BACKUP_SIGNING_KEY = "EC1301FD757E43F7";

    TMUX_TMPDIR = lib.mkForce "/tmp";

    EDITOR = "kak";
  };

  programs.command-not-found = {
    enable = true;
    dbPath = pkgs.runCommandLocal "programs.sqlite" {
      channelTarball = builtins.fetchurl "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
    } ''
      tar --wildcards -xJf $channelTarball '*/programs.sqlite'
      install -m 0644 */programs.sqlite $out
    '';
  };
}
