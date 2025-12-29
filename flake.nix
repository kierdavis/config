{
  description = "config";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-25.11";
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
    commonModules = [
      nix-index-database.nixosModules.nix-index
      secret.nixosModules.common
    ];
  in rec {
    nixosConfigurations = {
      coloris = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/machines/coloris.nix ] ++ commonModules;
      };

      saelli = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/machines/saelli.nix ] ++ commonModules;
      };
    };

    hydraJobs = {
      coloris = nixosConfigurations.coloris.config.system.build.toplevel;
      saelli = nixosConfigurations.saelli.config.system.build.toplevel;
    };
  };
}
