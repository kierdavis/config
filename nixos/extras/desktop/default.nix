{ config, lib, pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./dns-hack.nix
    ./etc.nix
    ./x11.nix
  ];

  # Plymouth splash screen during boot.
  boot.plymouth.enable = true;
}
