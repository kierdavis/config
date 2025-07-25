{ config, lib, pkgs, ... }:

{
  # bash completion
  programs.bash.completion.enable = true;

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
  programs.git.enable = true;
  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.less.enable = true;
  programs.traceroute.enable = true;
  environment.systemPackages = with pkgs; [
    # Utilities
    backblaze-b2
    bc
    ceph-client
    cryptsetup
    dmidecode
    file
    fzf
    gptfdisk
    iftop
    jq
    kakoune
    man-pages
    ncdu
    ntfs3g
    parallel
    parted
    pbzip2
    pigz
    psmisc  # provides killall
    pv
    rclone
    ripgrep
    rsync
    screen
    tree
    unzip
    wget
    zip

    # System diagnostics
    dnsutils  # dig
    fping
    jnettop
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
}
