{ config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/desktop
  ];

  machine = {
    name = "poutbox";
    wifi = false;
    ipv6-internet = false;
    cpu = {
      cores = 1;
      intel = false;
    };
    i3blocks = {
      cpuThermalZone = "XXX";
      ethInterface = "XXX";
      wlanInterface = "XXX";
    };
  };

  # XXX hack, this should be made optional
  services.syncthing.enable = lib.mkForce false;

  services.xserver.displayManager.lightdm.autoLogin = {
    enable = true;
    user = "kier";
  };
}
