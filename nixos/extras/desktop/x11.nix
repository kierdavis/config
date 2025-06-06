{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.openbox.enable = true;
  services.xserver.desktopManager.xterm.enable = false;  # creates unnecessary session types "xterm" and "xterm + i3"
  services.displayManager.defaultSession = "none+i3";
  services.xserver.videoDrivers = lib.optional config.machine.gpu.nvidia "nvidia";
  hardware.nvidia.open = false; # drivers that work plzz

  fonts.fontconfig.enable = true;
  services.xserver.dpi = 84;

  # SSH X11 forwarding
  services.openssh.settings.X11Forwarding = true;

  environment.systemPackages = [ pkgs.dconf ];

  # Fixes android-studio not being able to find the vulkan icd.d directory.
  environment.sessionVariables.XDG_DATA_DIRS = ["/run/opengl-driver/share"];
}
