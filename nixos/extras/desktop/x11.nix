{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.openbox.enable = true;
  services.xserver.desktopManager.xterm.enable = false;  # creates unnecessary session types "xterm" and "xterm + i3"
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.videoDrivers = lib.optional config.machine.gpu.nvidia "nvidia";
  #hardware.opengl.extraPackages = lib.optional config.machine.cpu.intel pkgs.intel-ocl;

  programs.nm-applet.enable = true;

  fonts.fontconfig.enable = true;
  fonts.fontconfig.dpi = 84;

  # SSH X11 forwarding
  services.openssh.forwardX11 = true;

  environment.systemPackages = [ pkgs.gnome3.dconf ];

  # Fixes android-studio not being able to find the vulkan icd.d directory.
  environment.sessionVariables.XDG_DATA_DIRS = ["/run/opengl-driver/share"];
}
