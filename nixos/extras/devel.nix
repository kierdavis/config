{ config, lib, pkgs, ... }:

let
  kubesh = pkgs.writeShellScriptBin "kubesh" ''
    exec ${pkgs.kubectl}/bin/kubectl --namespace kier-dev run --rm --stdin --tty --image=nixos/nix --restart=Never kubesh -- /bin/sh
  '';

in {
  # VirtualBox
  virtualisation.virtualbox.host.enable = true;

  virtualisation.podman.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    android-studio
    circleci
    modd
    (python3.withPackages (pyPkgs: with pyPkgs; [ virtualenv ]))

    # Kubernetes/containers
    buildah
    kubectl
    kubesh
    kubernetes-helm

    # Hardware
    geda
    pcb
    quartus

    # 3D modelling/printing
    freecad
    repetier-host
    slic3r-prusa3d

    # Accounting
    ledger
    marionette

    # Other
    keybase
    jq
    sr-tools
  ];

  services.keybase.enable = true;
  programs.adb.enable = true;

  documentation.dev.enable = lib.mkOverride 500 true;
}
