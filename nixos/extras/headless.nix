{ config, lib, pkgs, ... }:

let
  mkLowPriority = lib.mkOverride 200;  # 100 is the default priority

in {
  networking.wireless.enable = config.machine.wifi;

  #environment.noXlibs = mkLowPriority true;
  boot.vesa = mkLowPriority false;
  fonts.fontconfig.enable = mkLowPriority false;
  hardware.pulseaudio.enable = mkLowPriority false;
  programs.ssh.setXAuthLocation = mkLowPriority false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;
  services.xserver.enable = mkLowPriority false;
  sound.enable = mkLowPriority false;

  # Don't start a tty on the serial consoles.
  #systemd.services."serial-getty@ttyS0".enable = false;
  #systemd.services."serial-getty@hvc0".enable = false;
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@".enable = false;

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = mkLowPriority null;

  # Disable optional features of some packages to reduce dependency on graphics libraries.
  nixpkgs.overlays = [(self: super: {
    beets = super.beets.override {
      enableKeyfinder = false; # pulls in mesa-noglu
    };
    cairo = super.cairo.override {
      x11Support = false;
    };
    git = super.git.override {
      guiSupport = false;
    };
    gnupg22 = super.gnupg22.override {
      # 'true' removes gpg-agent, which breaks password-store.
      enableMinimal = false;
      # This option's name isn't very descriptive of what it actually does.
      # When true, gnupg uses "third-party" pinentry rather than an internal one.
      # This is fine since we configure "third-party" pinentry to build without GUI flavours.
      guiSupport = true;
    };
    ffmpeg = super.ffmpeg.override {
      sdlSupport = false;
      vdpauSupport = false;
    };
    gobject-introspection = super.gobject-introspection.override {
      x11Support = false;
    };
    pango = (super.pango.override {
      x11Support = false;
    }).overrideAttrs (superAttrs: {
      # docs fail to build when x11Support=false.
      mesonFlags = (lib.lists.remove "-Dgtk_doc=true" superAttrs.mesonFlags) ++ ["-Dgtk_doc=false"];
      outputs = lib.lists.remove "devdoc" superAttrs.outputs;
    });
    pass = super.pass.override {
      dmenu = null;
      qrencode = null;
      x11Support = false;
      xclip = null;
      xdotool = null;
      waylandSupport = false;
      wl-clipboard = null;
    };
    pinentry = super.pinentry.override {
      enabledFlavors = [ "curses" "tty" ];
    };
  })];
}
