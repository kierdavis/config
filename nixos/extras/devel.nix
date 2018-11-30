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

    # 3D modelling/printing
    freecad
    repetier-host

    # Other
    keybase
    x2goclient
  ];

  services.keybase.enable = true;
}
