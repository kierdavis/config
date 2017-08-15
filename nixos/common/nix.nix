{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;

in {
  nix.maxJobs = config.machine.cpu.cores;
  nix.buildCores = config.machine.cpu.cores;

  nixpkgs.config.allowUnfree = true;

  # Shared signing key.
  environment.etc."nix/signing-key.pub" = {
    text = secrets.keyPairs.nixSigning.public;
  };
  environment.etc."nix/signing-key.sec" = {
    mode = "0400";
    text = secrets.keyPairs.nixSigning.private;
  };

  nix.distributedBuilds = false;
  nix.buildMachines = lib.optional (config.machine.name != "coloris") {
    hostName = "192.168.1.20";
    maxJobs = 4;
    sshKey = "/etc/nix/id_nixbuild";
    sshUser = "nixbuild";
    system = "x86_64-linux";
  };

  environment.etc."nix/id_nixbuild" = {
    mode = "0400";
    text = secrets.keyPairs.nixbuildSSH.private;
  };

  users.users.nixbuild = {
    name = "nixbuild";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ secrets.keyPairs.nixbuildSSH.public ];
  };

#  nix.binaryCaches = [ "https://cache.nixos.org/" "file:///mnt/nocturn/nix-cache" ];
#  nix.trustedBinaryCaches = [ "file:///mnt/nocturn/nix-cache" ];
#  nix.binaryCachePublicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" secrets.keyPairs.nixCache.public ];
  environment.etc."nix/nix-cache.sec" = {
    mode = "0444";
    text = secrets.keyPairs.nixCache.private;
  };

  nix.gc = {
    automatic = true;
    dates = "19:00";
    options = "--delete-older-than 14d";
  };
}
