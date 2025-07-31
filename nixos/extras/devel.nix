{ config, lib, pkgs, ... }:

let
  kubesh = pkgs.writeShellScriptBin "kubesh" ''
    exec ${pkgs.kubectl}/bin/kubectl --namespace kier-dev run --rm --stdin --tty --image=nixos/nix --restart=Never kubesh -- /bin/sh
  '';

  ffmpegNvidia = pkgs.ffmpeg.override { withNpp = true; withUnfree = true; };

in {
  virtualisation.podman.enable = true;

  environment.systemPackages = with pkgs; [
    # Software
    cargo
    gcc  # provides linker for cargo
    (python3.withPackages (pyPkgs: with pyPkgs; [ virtualenv ]))

    # Infrastructure
    buildah
    crane
    kubectl
    kubernetes-helm
    kubesh
    restic
    talosctl
    terraform
    tfreveal

    # Media
    beets
    (if config.machine.gpu.nvidia then ffmpegNvidia else ffmpeg)

    git-filter-repo
  ];

  documentation.dev.enable = lib.mkOverride 500 true;
}
