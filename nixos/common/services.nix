{ config, lib, pkgs, ... }:

{
  # use timesyncd instead of ntpd
  services.ntp.enable = false;
  services.timesyncd.enable = true;

  # enable atd (a one-shot command scheduler)
  services.atd.enable = true;

  # ssh server
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    permitRootLogin = "without-password";
  };

  # Docker daemon
  virtualisation.docker = {
    enable = true;
  };
}
