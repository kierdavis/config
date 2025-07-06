{
  description = "config";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "kierdavis";
      repo = "nixpkgs";
      ref = "config";
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

  outputs = { self, nixpkgs, nix-index-database, secret, ... }: rec {
    nixosConfigurations = {
      coloris = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/machines/coloris.nix
          nix-index-database.nixosModules.nix-index
          secret.nixosModules.common
        ];
      };

      saelli = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/machines/saelli.nix
          nix-index-database.nixosModules.nix-index
          secret.nixosModules.common
        ];
      };
    };

    hydraJobs = {
      coloris = nixosConfigurations.coloris.config.system.build.toplevel;
      saelli = nixosConfigurations.saelli.config.system.build.toplevel;
    };
  };
}
