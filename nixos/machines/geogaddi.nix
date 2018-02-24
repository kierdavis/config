# Geogaddi is a docker container hosting network shares and other services.
# It is named after the album "Geogaddi" by "Boards of Canada".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/docker.nix
    ../extras/headless.nix
  ];

  machine = {
    name = "geogaddi";
    wifi = false;

    cpu = {
      cores = 8;
    };
  };

  networking.hostId = "62b585a5";

  campanella-vpn.client = {
    enable = true;
    certFile = "/nonvolatile/geogaddi.crt";
    keyFile = "/nonvolatile/geogaddi.key";
  };

  # Match my UID on the host system.
  users.users.kier.uid = lib.mkForce 1001;
}
