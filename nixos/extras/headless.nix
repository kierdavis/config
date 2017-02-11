{ config, lib, pkgs, ... }:

{
  networking.wireless.enable = config.machine.wifi;

  #environment.noXlibs = true;
  fonts.fontconfig.enable = false;
  hardware.pulseaudio.enable = false;
  programs.ssh.setXAuthLocation = false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;
  services.xserver.enable = false;
  sound.enable = false;

  nixpkgs.config.packageOverrides = pkgs: {
    dbus = pkgs.dbus.override { x11Support = false; };
  };
}
