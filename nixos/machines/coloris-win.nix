# Coloris is my workstation / gaming PC, built in 2016.
# It is named after the album "Coloris" by "she".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/wsl2
    ../extras/devel.nix
    ../extras/headless.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "coloris";
    cpu = {
      cores = 4;
    };
  };

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "bd7b28ce";

  services.syncthing.enable = lib.mkForce false;
}
