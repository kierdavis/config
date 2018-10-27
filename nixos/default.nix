let
  nixpkgs = import <nixpkgs> {};
  nixos = import <nixpkgs/nixos>;
in
  rec {
    coloris = (nixos {
      configuration = machines/coloris.nix;
      system = "x86_64-linux";
    }).system;

    ouroboros = (nixos {
      configuration = machines/ouroboros.nix;
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

    gyroscope = (nixos {
      configuration = machines/gyroscope.nix;
      system = "aarch64-linux";
    }).system;

    inshowha = (nixos {
     configuration = machines/inshowha.nix;
     system = "x86_64-linux";
    }).system;
  }
