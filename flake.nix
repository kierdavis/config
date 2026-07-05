{
  description = "config";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-26.05";
    };
    nix-index-database = {
      type = "github";
      owner = "nix-community";
      repo = "nix-index-database";
      ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secret = {
      type = "git";
      url = "git+ssh://git@git.personal.svc.kube.skaia.cloud/git-server/repos/config-secret";
      ref = "master";
    };
  };

  outputs = { self, nixpkgs, nix-index-database, secret, ... }: let
    system = "x86_64-linux";
    commonModules = [
      nix-index-database.nixosModules.nix-index
      secret.nixosModules.common
    ];
  in rec {
    nixosConfigurations = {
      coloris = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./nixos/machines/coloris.nix ] ++ commonModules;
      };

      saelli = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./nixos/machines/saelli.nix ] ++ commonModules;
      };
    };

    hydraJobs =
      builtins.mapAttrs (_: nixosCfg: nixosCfg.config.system.build.toplevel) nixosConfigurations
      // {
        installables = builtins.mapAttrs (_: nixosCfg: {
          inherit (nixosCfg.pkgs) arduino;
        }) nixosConfigurations;
      };
  };
}
