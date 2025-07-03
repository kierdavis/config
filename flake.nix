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

  outputs = { self, nixpkgs, ... }: {
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
  };
}
