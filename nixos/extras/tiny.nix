{ config, pkgs, lib, ... }: {
  nixpkgs.overlays = [ (import ../../patches/tiny.nix) ];
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
}
