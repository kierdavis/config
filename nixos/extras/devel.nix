{ config, lib, pkgs, ... }:

let
  kubesh = pkgs.writeShellScriptBin "kubesh" ''
    exec ${pkgs.kubectl}/bin/kubectl --namespace kier-dev run --rm --stdin --tty --image=nixos/nix --restart=Never kubesh -- /bin/sh
  '';

  # helm 3 hasn't made it into the release channel yet.
  pkgs-latest = import (fetchTarball https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz) {
    inherit (pkgs) config;
  };
  kubernetes-helm-latest = pkgs-latest.kubernetes-helm;

in {
  # Docker daemon
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
    };
  };

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    circleci
    modd
    (python3.withPackages (pyPkgs: with pyPkgs; [ virtualenv ]))

    # Kubernetes
    kubectl
    kubesh
    kubernetes-helm-latest

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
    sr-tools
    x2goclient
  ];

  services.keybase.enable = true;

  documentation.dev.enable = lib.mkOverride 500 true;
}
