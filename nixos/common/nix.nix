{ config, lib, pkgs, ... }:

{
  nix.useSandbox = true;
  nix.buildCores = config.machine.cpu.cores;
  # If there is more than one job running and they're all running make -j$buildCores -l$buildCores,
  # then system load will likely be higher than $buildCores and so each job ends up only using one core each.
  # So we might as well spawn one job per core.
  nix.maxJobs = config.machine.cpu.cores;

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = "Sat 03:00";
    options = "--delete-older-than 14d";
  };
  systemd.timers.nix-gc.timerConfig.Persistent = true;

  nix.nixPath = [
    "nixpkgs=/home/kier/config/nixpkgs"
    "nixos-config=/home/kier/config/nixos/machines/${config.machine.name}.nix"
  ];

  nixpkgs.overlays = [(import ../../pkgs/overlay.nix)];
}
