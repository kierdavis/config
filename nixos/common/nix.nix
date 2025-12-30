{ config, lib, pkgs, ... }:

{
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";

  nix.settings = {
    sandbox = true;
    cores = config.machine.cpu.cores;
    max-jobs = 2;
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "s3://nix-cache-4032b8ce-fa30-422f-8992-94f9c5cb1b3d?endpoint=http://rook-ceph-rgw-nix0.rook-ceph.svc.kube.skaia.cloud&profile=skaia-nix-cache" ];
    extra-trusted-public-keys = [ "hydra.personal.svc.kube.skaia.cloud-1:SFVF30Hf3FSqd3VX8nHhymQN9HkFL1PdLHQLmdMbDwE=" ];
  };

  # Can't use nix.envVars because that adds the variable to /etc/pam/environment,
  # which breaks other things (like websockets in google chrome).
  systemd.services.nix-daemon.environment.http_proxy = "http://nix-cache-proxy.personal.svc.kube.skaia.cloud:80";

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = "Sat 03:00";
    options = "--delete-older-than 7d";
  };
  systemd.timers.nix-gc.timerConfig.Persistent = true;

  nixpkgs.overlays = [(import ../../pkgs/overlay.nix)];
}
