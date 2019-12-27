{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.default = "i3";
  services.xserver.desktopManager.xterm.enable = false;  # creates unnecessary session types "xterm" and "xterm + i3"
  services.xserver.videoDrivers = lib.optional config.machine.gpu.nvidia "nvidia";
  #hardware.opengl.extraPackages = lib.optional config.machine.cpu.intel pkgs.intel-ocl;
  # Allow support for Direct Rendering for 32-bit applications e.g. Wine
  hardware.opengl.driSupport32Bit = true;

  programs.nm-applet.enable = true;

  fonts.fontconfig.enable = true;
  fonts.fontconfig.dpi = 84;

  # SSH X11 forwarding
  services.openssh.forwardX11 = true;

  environment.systemPackages = [ pkgs.gnome3.dconf ];
}
