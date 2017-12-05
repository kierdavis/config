{ config, lib, pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./audio.nix
    ./etc.nix
    ./x11.nix
  ];

  networking.networkmanager.enable = true;

  # Plymouth splash screen during boot.
  boot.plymouth.enable = true;
}
