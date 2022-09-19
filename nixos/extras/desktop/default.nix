{ config, lib, pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./i3blocks-config.nix
    ./x11.nix
  ];

  # Plymouth splash screen during boot.
  boot.plymouth.enable = true;
}
