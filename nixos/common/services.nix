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

  # Mail relay
  services.nullmailer = {
    enable = true;
    setSendmail = true;
    config = {
      me = config.machine.name;
      adminaddr = "me@kierdavis.com";  # All mail to localhost is redirected to this address.
      defaultdomain = "";
      remotes = ''
        aspmx.l.google.com smtp port=25 starttls
      '';
    };
  };

  # syncthing
  services.syncthing = {
    enable = true;
    dataDir = "/home/kier/.syncthing";
    openDefaultPorts = true;
    systemService = true;
    user = "kier";
    group = config.users.users.kier.group;
  };

  services.keybase.enable = true;
}
