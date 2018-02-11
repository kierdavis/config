let
  nixpkgs = import <nixpkgs> {};
  nixos = import <nixpkgs/nixos>;
in
  rec {
    machines = {
      coloris = (nixos {
        configuration = machines/coloris.nix;
        system = "x86_64-linux";
      }).system;

      ouroboros = (nixos {
        configuration = machines/ouroboros.nix;
        system = "x86_64-linux";
      }).system;

      nocturn = (nixos {
        configuration = machines/nocturn.nix;
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
    };

    all = {
      inherit (machines) coloris ouroboros nocturn saelli campanella2;
    };
  }
