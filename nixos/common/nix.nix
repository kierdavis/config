{ config, lib, pkgs, ... }:

{
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";

  nix.settings = {
    sandbox = true;
    cores = config.machine.cpu.cores;
    max-jobs = 2;
    experimental-features = [ "nix-command" "flakes" ];
    extra-trusted-public-keys = [ "hydra.personal.svc.kube.skaia.cloud-1:SFVF30Hf3FSqd3VX8nHhymQN9HkFL1PdLHQLmdMbDwE=" ];
  };

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = "Sat 03:00";
    options = "--delete-older-than 14d";
  };
  systemd.timers.nix-gc.timerConfig.Persistent = true;

  nixpkgs.overlays = [(import ../../pkgs/overlay.nix)];
}
