{ config, lib, pkgs, ... }:

{
  networking.wireless.enable = config.machine.wifi;

  #environment.noXlibs = true;
  boot.vesa = false;
  fonts.fontconfig.enable = false;
  hardware.pulseaudio.enable = false;
  programs.ssh.setXAuthLocation = false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;
  services.xserver.enable = false;
  sound.enable = false;

  # Don't start a tty on the serial consoles.
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];

  # Being headless, we don't need a GRUB splash image.
  boot.loader.grub.splashImage = null;
}
