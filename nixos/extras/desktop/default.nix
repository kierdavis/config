{ config, lib, pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./google-chrome.nix
    ./i3blocks-config.nix
    ./x11.nix
  ];

  # Plymouth splash screen during boot.
  boot.plymouth.enable = true;

  # required for fluidsynth
  security.pam.loginLimits = [
    { domain = "@audio"; type = "-"; item = "rtprio"; value = "90"; }
    { domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];
}
