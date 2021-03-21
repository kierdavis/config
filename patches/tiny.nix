self: super: {
  gnupg = super.gnupg.override {
    libusb1 = null;
    openldap = null;
    pcsclite = null;
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
