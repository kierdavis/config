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

  programs.gnupg.agent.enable = true;
}
