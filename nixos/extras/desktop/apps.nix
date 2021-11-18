{ config, lib, pkgs, ... }:

let
  hostname = config.machine.name;
  print3dPassword = (import ../../../secret/passwords.nix).user.fingerbib-3dprint.plain;
  print3dScript = pkgs.writeShellScriptBin "3dprint" ''
    exec ${pkgs.freerdp}/bin/xfreerdp /v:fingerbib /u:3dprint /p:${print3dPassword} /drive:${hostname},/
  '';

in {
  # redshift (adjusts colour temperature of displays at night)
  services.redshift.enable = true;

  # Backlight control
  programs.light.enable = true;

  # Other programs
  programs.adb.enable = false;
  programs.steam.enable = true;
  virtualisation.virtualbox.host.enable = true;
  environment.systemPackages = with pkgs; [
    citrix_workspace
    cups  # client
    dmenu
    evince
    gimp
    gnome3.eog
    i3blocks
    i3blocks-scripts
    i3lock
    pavucontrol
    pinentry-gnome
    screenshot
    signal-desktop
    spotify
    terminator
    tor-browser-bundle-bin
    vlc
    zoom-us

    # Development
    blender
    freecad
    geda
    kicad
    pcb
    print3dScript
    quartus
  ];

  # For spotify to sync local files to other devices on the LAN via uPnP:
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 57621 ];
  };

  environment.variables.CUPS_SERVER = "printing.hist:80";
  environment.variables.PRINTER = "HP_Envy_5640";
}
