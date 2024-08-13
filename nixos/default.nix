let
  nixos = import <nixpkgs/nixos>;
in
  rec {
    coloris = nixos {
      configuration = machines/coloris.nix;
      system = "x86_64-linux";
    };

    saelli = nixos {
      configuration = machines/saelli.nix;
      system = "x86_64-linux";
    };
  }
