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

    campanella2 = (nixos {
      configuration = machines/campanella2.nix;
      system = "x86_64-linux";
    }).system;

    bonito = (nixos {
     configuration = machines/bonito.nix;
     system = "x86_64-linux";
    }).system;

    cherry = (nixos {
      configuration = machines/cherry.nix;
      system = "x86_64-linux";
    }).system;
  }
