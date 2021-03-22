{ config, lib, pkgs, ... }:

let
  kubesh = pkgs.writeShellScriptBin "kubesh" ''
    exec ${pkgs.kubectl}/bin/kubectl --namespace kier-dev run --rm --stdin --tty --image=nixos/nix --restart=Never kubesh -- /bin/sh
  '';

in {
  virtualisation.podman.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    cargo
    modd
    (python3.withPackages (pyPkgs: with pyPkgs; [ virtualenv ]))
    rustfmt

    # Kubernetes/containers
    buildah
    kubectl
    kubesh
    kubernetes-helm

    # Accounting
    ledger
    marionette

    # Other
    keybase
    jq
    sr-tools
  ];

  services.keybase.enable = true;

  documentation.dev.enable = lib.mkOverride 500 true;
}
