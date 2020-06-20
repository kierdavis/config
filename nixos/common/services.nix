{ config, lib, pkgs, ... }:

{
  # use timesyncd instead of ntpd
  # Explicit lower-than-usual priority of 150 is needed
  # so that <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
  # can override this setting at the default priority of 100.
  services.ntp.enable = false;
  services.timesyncd.enable = lib.mkOverride 150 true;

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
    enable = false;
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
    guiAddress = "[${(import ../cascade.nix).hostAddrs."${config.machine.name}"}]:8384";
  };
  networking.firewall.allowedTCPPorts = [ 8384 ];

  programs.gnupg.agent.enable = true;
}
