let
  nixpkgs = import <nixpkgs> {};
  nixos = import <nixpkgs/nixos>;
in
  rec {
    coloris = nixos {
      configuration = machines/coloris.nix;
      system = "x86_64-linux";
    };

    coloris-win = nixos {
      configuration = machines/coloris-win.nix;
      system = "x86_64-linux";
    };

    saelli = nixos {
      configuration = machines/saelli.nix;
      system = "x86_64-linux";
    };
  }
