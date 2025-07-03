{
  description = "config/nixos";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "kierdavis";
      repo = "nixpkgs";
      rev = "b43c397f6c213918d6cfe6e3550abfe79b5d1c51";
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
