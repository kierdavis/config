{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;

in {
  nix.maxJobs = config.machine.cpu.cores;

  nixpkgs.config.allowUnfree = true;

  # Shared signing key.
  environment.etc."nix/signing-key.pub" = {
    text = secrets.keyPairs.nixSigning.public;
  };
  environment.etc."nix/signing-key.sec" = {
    mode = "0400";
    text = secrets.keyPairs.nixSigning.private;
  };

  nix.gc = {
    automatic = true;
    dates = "Mon 19:00";
    options = "--delete-older-than 14d";
  };
}
