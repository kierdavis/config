{ config, lib, pkgs, ... }:

{
  # Docker daemon
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
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
