{ config, lib, pkgs, ... }:

let
  secrets = import ../../secret;

in {
  nix.buildCores = config.machine.cpu.cores;

  nixpkgs.config.allowUnfree = true;

  # Shared signing key.
  environment.etc."nix/signing-key.pub" = {
    text = secrets.nix-signing-key.pub;
  };
  environment.etc."nix/signing-key.sec" = {
    mode = "0400";
    text = secrets.nix-signing-key.priv;
  };

  nix.gc = {
    automatic = true;
    dates = "Mon 19:00";
    options = "--delete-older-than 14d";
  };
  systemd.timers.nix-gc.timerConfig.Persistent = true;
}
