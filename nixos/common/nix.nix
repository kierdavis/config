{ config, lib, pkgs, ... }:

{
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";

  nix.settings = {
    sandbox = true;
    cores = config.machine.cpu.cores;
    max-jobs = 2;
    experimental-features = [ "nix-command" "flakes" ];
  };

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
