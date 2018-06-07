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

    solanin = (nixos {
      configuration = machines/solanin.nix;
      system = "armv7l-linux";
    }).system;

    gyroscope = (nixos {
      configuration = machines/gyroscope.nix;
      system = "aarch64-linux";
    }).system;
  }
