{ config, lib, pkgs, ... }:

{
  # use timesyncd instead of ntpd
  services.ntp.enable = false;
  services.timesyncd.enable = true;

  # ssh server
  services.openssh = {
    enable = true;
    forwardX11 = true;
    passwordAuthentication = true;
    permitRootLogin = "without-password";
  };
}
