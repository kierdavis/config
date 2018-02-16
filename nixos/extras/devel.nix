{ config, lib, pkgs, ... }:

let
  localPkgs = import ../../pkgs pkgs;

in {
  # Docker daemon
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
    };
  };

  environment.systemPackages = with localPkgs; [
    # Software
    circleci
    python2
    python3

    # Hardware
    geda
    kicad
    pcb
  ];
}
