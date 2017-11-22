{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager.xterm.enable = false;  # creates unnecessary session types "xterm" and "xterm + i3"
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.extraPackages = lib.optional config.machine.cpu.intel pkgs.intel-ocl;
  # Allow support for Direct Rendering for 32-bit applications e.g. Wine
  hardware.opengl.driSupport32Bit = true;

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.networkmanagerapplet}/bin/nm-applet &
  '';

  fonts.fontconfig.enable = true;
  fonts.fontconfig.dpi = 84;

  # SSH X11 forwarding
  services.openssh.forwardX11 = true;

  users.users.kier.extraGroups = ["video"];
}
