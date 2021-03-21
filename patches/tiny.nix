self: super: {
  gnupg = super.gnupg.override {
    # 'true' removes gpg-agent, which breaks password-store.
    enableMinimal = false;
    # This option's name isn't very descriptive of what it actually does.
    # When true, gnupg uses "third-party" pinentry rather than an internal one.
    # This is fine since we configure "third-party" pinentry to build without GUI flavours.
    guiSupport = true;
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
