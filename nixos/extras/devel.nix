{ config, lib, pkgs, ... }:

let
  kubesh = pkgs.writeShellScriptBin "kubesh" ''
    exec ${pkgs.kubectl}/bin/kubectl --namespace kier-dev run --rm --stdin --tty --image=nixos/nix --restart=Never kubesh -- /bin/sh
  '';

in {
  virtualisation.podman.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    (python3.withPackages (pyPkgs: with pyPkgs; [ virtualenv ]))

    # Infrastructure
    buildah
    cue
    kubectl
    kubesh
    talosctl
    terraform

    # Other
    duplicity
    fina
    keybase
    sr-tools
  ];

  services.keybase.enable = true;

  documentation.dev.enable = lib.mkOverride 500 true;
}
