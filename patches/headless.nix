self: super: {
  beets = super.beets.override {
    enableKeyfinder = false; # pulls in mesa-noglu
  };
  # cairo = super.cairo.override {
  #   x11Support = false;
  # };
  gnupg = super.gnupg.override {
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
}
