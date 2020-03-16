self: super: {
  ffmpeg = super.ffmpeg.override {
    sdlSupport = false;
    vdpauSupport = false;
  };
  gobject-introspection = super.gobject-introspection.override {
    x11Support = false;
  };
  gnupg = super.gnupg.override {
    guiSupport = false;
    libusb = null;
    openldap = null;
  };
  nix = super.nix.override {
    withLibseccomp = false;
    withAWS = false;
  };
  rng-tools = super.rng-tools.override {
    withPkcs11 = false;
  };
  udisks = super.udisks.override {
    xfsprogs = null;
    f2fs-tools = null;
    btrfs-progs = null;
    nilfs-utils = null;
    ntfs3g = null;
  };
}
