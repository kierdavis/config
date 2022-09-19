# Shrink size of system closure.
# Generally only used when having to compile the entire system from source.

{ config, pkgs, lib, ... }: {
  boot.plymouth.enable = lib.mkForce false;
  fonts.fontconfig.enable = lib.mkForce false;
  programs.command-not-found.enable = lib.mkForce false;
  services.udisks2.enable = lib.mkForce false;
  services.timesyncd.enable = lib.mkForce false;
  services.atd.enable = lib.mkForce false;
  services.syncthing.enable = lib.mkForce false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;
  xdg.mime.enable = lib.mkForce false;
  nix.gc.automatic = lib.mkForce false;
  documentation = {
    enable = lib.mkForce false;
    nixos.enable = lib.mkForce false;
    dev.enable = lib.mkForce false;
    man.enable = lib.mkForce false;
    info.enable = lib.mkForce false;
    doc.enable = lib.mkForce false;
  };

  # Disable optional features of some packages.
  nixpkgs.overlays = [(self: super: {
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
  })];
}
