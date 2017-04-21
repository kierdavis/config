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
    };

    texlive = nixpkgs.texlive.combined.scheme-full;

    all = {
      inherit (machines) coloris ouroboros nocturn;
      inherit texlive;
    };
  }
