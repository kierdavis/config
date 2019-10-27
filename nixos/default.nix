let
  nixpkgs = import <nixpkgs> {};
  nixos = import <nixpkgs/nixos>;
in
  rec {
    coloris = (nixos {
      configuration = machines/coloris.nix;
      system = "x86_64-linux";
    }).system;

    saelli = (nixos {
      configuration = machines/saelli.nix;
      system = "x86_64-linux";
    }).system;
  }
