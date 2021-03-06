{ config, lib, pkgs, ... }:

{
  nix.useSandbox = true;
  nix.buildCores = config.machine.cpu.cores;
  nix.maxJobs = 2;

  nixpkgs.config.allowUnfree = true;

  # Shared signing key.
  environment.etc."nix/signing-key.pub" = {
    source = ../../secret/nix-signing-key.pub;
  };
  environment.etc."nix/signing-key.sec" = {
    source = ../../secret/nix-signing-key.priv;
  };
  nix.binaryCachePublicKeys = [
    (builtins.readFile ../../secret/nix-signing-key.pub)
  ];
  environment.variables.NIX_SECRET_KEY_FILE = "/etc/nix/signing-key.sec";

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
