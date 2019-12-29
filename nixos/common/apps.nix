{ config, lib, pkgs, ... }:

let
  mkWake = name: mac: pkgs.writeShellScriptBin "wake-${name}" ''
    ${pkgs.wakelan}/bin/wakelan ${mac}
  '';

  nixos-rebuild-remote = pkgs.writeShellScriptBin "nixos-rebuild-remote" ''
    set -o errexit -o nounset -o pipefail
    host="$1"
    shift
    ping -c1 "$host"
    ssh_dir=/home/kier/.ssh
    ssh_key=$ssh_dir/$(ls $ssh_dir | grep -E '^id_(rsa|ed25519)$')
    exec nixos-rebuild --builders "ssh://nixremotebuild@$host - $ssh_key 4 - big-parallel" --max-jobs 0 "$@"
  '';

  kubesh = pkgs.writeShellScriptBin "kubesh" ''
    exec ${pkgs.kubectl}/bin/kubectl --namespace kier-dev run --rm --stdin --tty --image=nixos/nix --restart=Never kubesh -- /bin/sh
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
    kakoune
    kubectl
    kubesh
    manpages
    mountext
    nixos-rebuild-remote
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
    dnsutils  # dig
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
