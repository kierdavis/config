{ config, lib, pkgs, ... }:

let
  hostname = config.machine.name;

  blenderCuda = (pkgs.blender.override {
    cudaSupport = true;
  }).overrideDerivation ({ preBuild ? "", ... }: {
    # NIX_BUILD_CORES >= 3 requires more than 8GB memory.
    # TODO: compute min(num cores, GB memory / 3) at runtime rather than hardcoding a value.
    preBuild = ''
      export NIX_BUILD_CORES=2
      ${preBuild}
    '';
  });

in {
  # redshift (adjusts colour temperature of displays at night)
  services.redshift.enable = true;

  # Backlight control
  programs.light.enable = true;

  # Thumbnailer daemon (needed if you want to see thumbnails of image files in thunar, etc).
  services.tumbler.enable = true;
  # If a package provides any $out/share/thumbnailers/*.thumbnailer files,
  # add $out/share to the list below and tumbler will make use of it.
  environment.sessionVariables.XDG_DATA_DIRS = [
    "${pkgs.ffmpegthumbnailer}/share"
  ];

  # Other programs
  programs.chromium.enable = true;
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    audacity
    autorandr
    (if config.machine.gpu.nvidia then blenderCuda else blender)
    cups  # client
    darktable
    dmenu
    eog
    evince
    freecad
    gimp
    google-chrome
    i3blocks
    (i3blocks-scripts.override { withNvidiaSupport = config.machine.gpu.nvidia; })
    i3lock
    inkscape
    librecad
    pinentry-gnome3
    # polymc  # multimc successor
    prusa-slicer
    # quartus
    # renoise
    screenshot
    spotify
    terminator
    tor-browser-bundle-bin
    vlc
    xfce.thunar
    zoom-us

    # Lots of apps assume that Google Chrome, if installed, will be discoverable
    # on $PATH as 'google-chrome'. Not really sure why NixOS needs to give it a
    # silly name.
    (pkgs.runCommand "google-chrome" {} ''
      mkdir -p "$out/bin"
      ln -sfT "${pkgs.google-chrome}/bin/google-chrome-stable" "$out/bin/google-chrome"
    '')
  ];

  # For spotify to sync local files to other devices on the LAN via uPnP:
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 57621 ];
  };

  # Hack to make Google Chrome send DNS AAAA queries in addition to A queries even if the machine has no IPv6 internet connection.
  #networking.interfaces.lo.ipv6.routes = lib.optional (!config.machine.ipv6-internet) {
  #  address = "2001:4860:4860::8888";
  #  prefixLength = 128;
  #};
}
