self: super: {
  beets = super.beets.override {
    enableKeyfinder = false; # pulls in mesa-noglu
  };
  # cairo = super.cairo.override {
  #   x11Support = false;
  # };
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
