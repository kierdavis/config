{
  description = "config/nixos";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "kierdavis";
      repo = "nixpkgs";
      ref = "config";
    };
  };

  outputs = { self, nixpkgs, nixosConfigurations, ... }: {
    nixosConfigurations = {
      coloris = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/machines/coloris.nix ];
      };
      saelli = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/machines/saelli.nix ];
      };
    };

    hydraJobs = {
      coloris = nixosConfigurations.coloris.config.system.build.toplevel;
      saelli = nixosConfigurations.saelli.config.system.build.toplevel;
    };
  };
}
