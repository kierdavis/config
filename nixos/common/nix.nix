{ config, lib, pkgs, ... }:

{
  nix.useSandbox = true;
  nix.buildCores = config.machine.cpu.cores;

  nixpkgs.config.allowUnfree = true;

  # Shared signing key.
  environment.etc."nix/signing-key.pub" = {
    source = ../../secret/nix-signing-key.pub;
  };
  environment.etc."nix/signing-key.sec" = {
    mode = "0400";
    text = builtins.readFile ../../secret/nix-signing-key.priv;
  };

  nix.gc = {
    automatic = true;
    dates = "Mon 19:00";
    options = "--delete-older-than 14d";
  };
  systemd.timers.nix-gc.timerConfig.Persistent = true;

  nixpkgs.overlays = [
    (import ../../pkgs/overlay.nix)
    (self: super: {
      jemalloc = super.callPackage ../lib/jemalloc.nix {};
    })
  ];
}
