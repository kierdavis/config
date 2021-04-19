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
  # bash completion
  programs.bash.enableCompletion = true;

  # documentation
  documentation = {
    enable = true;
    nixos.enable = lib.mkOverride 500 true;
    dev.enable = false;

    # Types of documentation
    man.enable = true;
    info.enable = true;
    doc.enable = false; # anything that doesn't fall into the above two categories
  };

  programs.tmux = {
    enable = true;
    escapeTime = 0;
    extraConfig = ''
      # There was some issue with Home and End keys not working properly, and this fixed it:
      bind-key -n Home send Escape "OH"
      bind-key -n End send Escape "OF"

      # When creating new panes or windows, use the same working directory as the currently selected pane instead of defaulting to $HOME.
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window  # -c "#{pane_current_path}"

      # This key did something really annoying (move current pane into its own window, perhaps) and I kept hitting it by mistake:
      unbind !
    '';
  };

  # other programs
  programs.iotop.enable = true;
  programs.less.enable = true;
  programs.traceroute.enable = true;
  environment.systemPackages = with pkgs; [
    # Utilities
    bc
    file
    fzf
    git
    gptfdisk
    jq
    kakoune
    manpages
    mountext
    nixos-rebuild-remote
    pbzip2
    pigz
    psmisc  # provides killall
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
    lshw
    lsof
    nmap
    pciutils  # lspci
    sysstat   # iostat
    tcpdump
    usbutils  # lsusb

    # Security
    gnupg
    pass
    passchars
    pinentry-curses
  ];

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
