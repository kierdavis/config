{ config, lib, pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./etc.nix
    ./google-chrome.nix
    ./x11.nix
  ];

  # Plymouth splash screen during boot.
  boot.plymouth.enable = true;
}
