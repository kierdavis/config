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
    python3

    # Hardware
    geda
    pcb
    quartus

    # 3D modelling/printing
    freecad
    repetier-host
    slic3r-prusa3d

    # Other
    keybase
    x2goclient
  ];

  services.keybase.enable = true;

  documentation.dev.enable = lib.mkOverride 500 true;
}
