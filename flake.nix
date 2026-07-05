{
  description = "config";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-25.11";
    };
    nixpkgs-bleeding-edge = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "staging-next";
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

  outputs = { self, nixpkgs, nixpkgs-bleeding-edge, nix-index-database, secret, ... }: let
    system = "x86_64-linux";
    pkgs-bleeding-edge = import nixpkgs-bleeding-edge {
      inherit system;
    };
    commonModules = [
      nix-index-database.nixosModules.nix-index
      secret.nixosModules.common
      ({
        nixpkgs.overlays = [(self: super: {
          inherit (pkgs-bleeding-edge) talosctl;
        })];
      })
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
